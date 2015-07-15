<?php
/**
 * psql.php
 *
 * this is the model about postgresql for terrecord
 *
 * @author Keisuke Mutoh <kmutoh@lefthandle.com>
 * @version 1.0
 * @package terrecord
 * @copyright Team Left Handle (http://lefthandle.com)
 * @license http://www.opensource.org/licenses/mit-license.php MIT
 */

 /**
  * class Psql
  *
  * this is the model about postgresql for terrecord
  *
  * @package terrecord
  */

class Psql extends Scheme
{
    /**
     * get instance (singleton)
     *
     * @access public
     * @return Psql 
     */
    public static function getInstance() {
        if(Psql::$scheme == null) {
            Psql::$scheme = new Psql();
        }
        return Psql::$scheme;
    }

    /**
     * connect to database
     *
     * @access protected
     */
    protected function connect() {
        if(!is_null($this->db)) {
            return;
        }

        $dsn = 'pgsql:';
        if ($this->config['host']!='') {
            $dsn .= 'host='.$this->config['host'];
        } else {
            $dsn .= 'host=localhost';
        }
        if ($this->config['port']!='') {
            $dsn .= ' port='.$this->config['port'];
        } else {
            $dsn .= ' port=5432';
        }
        if ($this->config['dbname']!='') {
            $dsn .= ' dbname='.$this->config['dbname'];
        } else {
            throw new UnexpectedValueException(_("Please set database name on your configuration..."));    
        }
        if (!isset($this->config['user']) || $this->config['user']=='') {
            throw new UnexpectedValueException(_("Please set user name for database on your configuration..."));    
        }
        if (!isset($this->config['password'])) {
            throw new UnexpectedValueException(_("Please set password for database on your configuration..."));    
        }

        $this->db = new PDO($dsn, $this->config['user'], $this->config['password'], array(PDO::ATTR_PERSISTENT => false));
        $this->db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return;
    }

    /**
     * get table definition
     *
     * @access protected
     * @var array
     */
    protected function getTableDef() {
        // get list of user tabels
        $sql = "SELECT DISTINCT";
        $sql .= ' pg_class.relname as "Name"';
        $sql .= ', pg_description.description as "Comment"';
        $sql .= " FROM";
        $sql .= " pg_class";
        $sql .= " INNER JOIN pg_tables ON";
        $sql .= " pg_class.relname = pg_tables.tablename";
        $sql .= " LEFT JOIN pg_description ON";
        $sql .= " pg_class.oid = pg_description.objoid AND";
        $sql .= " pg_description.objsubid = 0";
        $sql .= " WHERE";
        $sql .= " schemaname = 'public' AND";
        $sql .= " pg_class.relkind = 'r';";
        $stmt = $this->db->query($sql);
        $this->tabledef = $stmt->fetchAll();
    }

    /**
     * get field definition
     *
     * @access protected
     * @var array
     */
    protected function getFieldDef() {
        foreach($this->tabledef as $key => $table) {
            // get fields
            $sql = "SELECT DISTINCT";
            $sql .= ' pg_attribute.attname as "Field"';
            $sql .= ', pg_type.typname as "Type"';
            $sql .= ', pg_attribute.atttypmod as "subtype"';
            $sql .= ', pg_attrdef.adsrc as "Default"';
            $sql .= ", CASE pg_attribute.attnotnull WHEN 't' THEN 'NOT NULL' WHEN 'f' THEN 'NULL' END ".'as "Null"';
            $sql .= ', pg_description.description as "Comment"';
            $sql .= ', pg_attribute.attnum as "no"';
            $sql .= " FROM";
            $sql .= " pg_attribute";
            $sql .= " INNER JOIN pg_class ON";
            $sql .= " pg_class.oid = pg_attribute.attrelid";
            $sql .= " INNER JOIN pg_type ON";
            $sql .= " pg_attribute.atttypid = pg_type.oid";
            $sql .= " LEFT JOIN pg_description ON";
            $sql .= " pg_class.oid = pg_description.objoid AND";
            $sql .= " pg_attribute.attnum = pg_description.objsubid";
            $sql .= " LEFT JOIN pg_attrdef ON";
            $sql .= " pg_attribute.attrelid = pg_attrdef.adrelid AND";
            $sql .= " pg_attribute.attnum = pg_attrdef.adnum";
            $sql .= " WHERE";
            $sql .= " pg_class.relname='".$table["Name"]."' AND";
            $sql .= " pg_attribute.attnum > 0";
            $sql .= "  ORDER BY pg_attribute.attnum;";
            $stmt = $this->db->query($sql);
            $this->fielddef[$key] = $stmt->fetchAll();
        }
    }
        
    /**
     * get primary key definition
     *
     * @access protected
     * @var array
     */
    protected function getPkeyDef() {
        foreach($this->tabledef as $key => $table) {
            $sql = "SELECT";
            $sql .= ' c.relname as "Table"';
            $sql .= ', a.attname as "Column"';
            $sql .= " FROM";
            $sql .= " pg_constraint n";
            $sql .= " INNER JOIN pg_class c ON";
            $sql .= " n.conrelid = c.oid";
            $sql .= " INNER JOIN pg_attribute a ON";
            $sql .= " a.attrelid = c.oid";
            $sql .= " WHERE";
            $sql .= " a.attnum = ANY(n.conkey)";
            $sql .= " AND c.relname = '".$table["Name"]."'";
            $sql .= " AND n.contype = 'p'";
            $sql .= " ORDER BY a.attnum;";
            $stmt = $this->db->query($sql);
            $this->pkeydef[$key] = $stmt->fetchAll();
        }
    }
        
    /**
     * get index definition
     *
     * @access protected
     * @var array
     */
    protected function getIndexDef() {
        foreach($this->tabledef as $key => $table) {
            $sql = "SELECT";
            $sql .= ' c.relname as "TABLE_NAME"';
            $sql .= ', a.attname as "COLUMN_NAME"';
            $sql .= ', fclass.relname as "REFERENCED_TABLE_NAME"';
            $sql .= ', fattr.attname as "REFERENCED_COLUMN_NAME"';
            $sql .= " FROM";
            $sql .= " pg_constraint n";
            $sql .= " INNER JOIN pg_class c ON";
            $sql .= " n.conrelid = c.oid";
            $sql .= " INNER JOIN pg_attribute a ON";
            $sql .= " a.attrelid = c.oid";
            $sql .= " LEFT JOIN pg_class fclass ON";
            $sql .= " n.confrelid = fclass.oid";
            $sql .= " LEFT JOIN pg_attribute fattr ON";
            $sql .= " fattr.attrelid = c.oid AND";
            $sql .= " fattr.attnum = ANY(n.conkey)";
            $sql .= " WHERE";
            $sql .= " a.attnum = ANY(n.conkey)";
            $sql .= " AND c.relname = '".$table["Name"]."'";
            $sql .= " ORDER BY a.attnum;";
            $stmt = $this->db->query($sql);
            $this->indexdef[$key] = $stmt->fetchAll();
        }
    }

    /**
     * get default value
     *
     * @access protectedp
     * @return string default value
     */
    protected function getDefaultValue($phptype,$type,$default)
    {
        switch($phptype) {
        case "integer":
            if(mb_strpos($default,"nextval")!==false) {
                return (string)"0";
            } else if($default!="") {
                switch($type) {
                case "timestamp":
                case "timestamptz":
                    return (string)"0";
                    break;
                case "interval":
                case "date":
                case "time":
                case "timetz":
                    return (string)"''";
                    break;
                default:
                    return (string)$default;
                }
            } else {
                return (string)"0";
            }
            break;
        case "float":
            if($default!="") {
                return (string)$default;
            } else {
                return (string)"0.0";
            }
            break;
        case "boolean":
            if($default!="") {
                return (string)$default;
            } else {
                return (string)"false";
            }
            break;
        case "string":
            if($default!="") {
                switch($type) {
                case "char":
                case "bpchar":
                case "varchar":
                case "text":
                case "name":
                case "bytea":
                case "cidr":
                case "inet":
                case "macaddr":
                    if(mb_ereg("(.*)::",$default,$regs)) {
                        $str = mb_ereg_replace("'","",$regs[1]);
                        return "'".$str."'";
                    } else {
                        return "''";
                    }
                    break;
                default:
                    return "''";
                }            
            } else {
                return "''";
            }
            break;
        case "binary":
            return "''";
            break;
        case "mixed":
            return (string)"null";
            break;
        }
    }

    /**
     * convert value type
     *
     * @access protected
     * @return string value type
     */
    protected function convertType($type)
    {
        switch($type) {
        case "int2":
        case "int4":
        case "int8":
            return "integer";
            break;
        case "numeric":
        case "float4":
        case "float8":
            return "float";
            break;
        case "bool":
            return "boolean";
            break;
        case "char":
        case "bpchar":
        case "varchar":
        case "text":
        case "name":
            return "string";
            break;
        case "bytea":
            return "binary";
            break;
        case "timestamp":
        case "timestamptz":
            return "integer";
            break;
        case "interval":
        case "date":
        case "time":
        case "timetz":
            return "string";
            break;
        case "point":
        case "lseg":
        case "box":
        case "path":
        case "polygon":
        case "circle":
            return "object";
            break;
        case "cidr":
        case "inet":
        case "macaddr":
            return "string";
            break;
        default:
            return "mixed";
            break;
        }
    }

    /**
     * convert sub type of value
     *
     * @access protected
     * @return integer
     */
    protected function convertSubtype($phptype,$subtype)
    {
        if($subtype==-1) {
            return 0;
        } else if($phptype=="string" && $subtype!="-1") {
            return $subtype - 4;
        } else if($phptype=="float" && $subtype!="-1") {
            return intval(($subtype - 4)/65536).".".(($subtype - 4)%65536);
        } else {
            return (string)'null';
        }
    }
}
?>
