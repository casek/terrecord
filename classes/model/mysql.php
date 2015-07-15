<?php
/**
 * mysql.php
 *
 * this is the model about mysql for terrecord
 *
 * @author Keisuke Mutoh <kmutoh@lefthandle.com>
 * @version 1.0
 * @package terrecord
 * @copyright Team Left Handle (http://lefthandle.com)
 * @license http://www.opensource.org/licenses/mit-license.php MIT
 */

 /**
  * class Mysql
  *
  * this is the model about mysql for terrecord
  *
  * @package terrecord
  */

class Mysql extends Scheme
{
    /**
     * get instance (singleton)
     *
     * @access public
     * @return Mysql
     */
    public static function getInstance() {
        if(Mysql::$scheme == null) {
            Mysql::$scheme = new Mysql();
        }
        return Mysql::$scheme;
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
        
        $dsn = 'mysql:';
        if($this->config['socket']!='') {
            $dsn .= 'unix_socket='.$this->config['socket'];
        } else {
            if ($this->config['host']!='') {
                $dsn .= 'host='.$this->config['host'];
            } else {
                $dsn .= 'host=localhost';
            }
            if ($this->config['port']!='') {
                $dsn .= ';port='.$this->config['port'];
            } else {
                $dsn .= ';port=3306';
            }
        }
        if ($this->config['dbname']!='') {
            $dsn .= ';dbname='.$this->config['dbname'];
        } else {
            throw new UnexpectedValueException(_("Please set database name on config file..."));    
        }
        if ($this->config['encoding']!='') {
            $dsn .= ';charset='.$this->config['encoding'];
        } else {
            $dsn .= ';charset=utf8';
        }
        if (!isset($this->config['user']) || $this->config['user']=='') {
            throw new UnexpectedValueException(_("Please set user name for database on your configuration..."));    
        }
        if (!isset($this->config['password'])) {
            throw new UnexpectedValueException(_("Please set password for database on your configuration..."));    
        }
        $this->db = new PDO($dsn, $this->config['user'], $this->config['password'], array(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY => true, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION));
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
        $sql = "show table status";
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
            $sql = "show full columns from ".$table['Name'].";";
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
        $pkeydef = array();
        foreach($this->tabledef as $key => $table) {
            $sql = "show full columns from ".$table['Name'].";";
            $stmt = $this->db->query($sql);
            $fields = $stmt->fetchAll();
            foreach($fields as $field) {
                if($field['Key'] == 'PRI') {
                    $pkeydef[$key][] = array(
                        'Table' => $table['Name'],
                        'Column' => $field['Field']
                    );
                }
            }
        }
        $this->pkeydef = $pkeydef;
    }
        
    /**
     * get index definition
     *
     * @access protected
     * @var array
     */
    protected function getIndexDef() {
        foreach($this->tabledef as $key => $table) {
            $sql = "select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE where CONSTRAINT_SCHEMA = '".$this->config['dbname']."' and TABLE_NAME = '".$table['Name']."'";
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
            if ($default!="") {
                switch($type) {
                case "timestamp":
                    return (string)"0";
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
                return (string)$default;
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
        $type = strtolower($type);
        if($res = mb_ereg_replace(" unsigned","",$type)) {
            $type = $res;
        }
        if($res = mb_ereg_replace(" zerofill","",$type)) {
            $type = $res;
        }
        if($res = mb_ereg_replace("national ","",$type)) {
            $type = $res;
        }
        if($res = mb_ereg_replace(" character set ([^ ]*)","",$type)) {
            $type = $res;
        }
        if($res = mb_ereg_replace(" collate ([^ ]*)","",$type)) {
            $type = $res;
        }
        $regs = array();
        if(mb_ereg("(.*)\((.*)\)",$type,$regs)) {
            $type = $regs[1];
        }

        switch($type) {
        case "int":
        case "tinyint":
        case "smallint":
        case "midiumint":
        case "bigint":
        case "serial":
        case "integer":
        case "bit":
            return "integer";
            break;
        case "double":
        case "double precision":
        case "real":
        case "float":
        case "decimal":
        case "dec":
        case "numeric":
        case "fixed":
            return "float";
            break;
        case "bool":
        case "boolean":
            return "boolean";
            break;
        case "char":
        case "varchar":
        case "tinytext":
        case "text":
        case "mediumtext":
        case "longtext":
            return "string";
            break;
        case "binary":
        case "varbinary":
        case "tinyblob":
        case "blob":
        case "mediumblob":
        case "longblob":
            return "binary";
            break;
        case "timestamp":
            return "integer";
            break;
        case "date":
        case "datetime":
        case "time":
        case "year":
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
    protected function convertSubtype($phptype,$dbtype)
    {
        $length = (string)'null';
        $regs = array();
        if(mb_ereg("(.*)\((.*)\)",$dbtype,$regs)) {
            $dbtype = $regs[1];
            $length = $regs[2];
        }
        return $length;
    }
}
?>
