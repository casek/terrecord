<?php
/**
 * scheme.php
 *
 * this is the model for terrecord
 *
 * @author Keisuke Mutoh <kmutoh@lefthandle.com>
 * @version 1.0
 * @package terrecord
 * @copyright Team Left Handle (http://lefthandle.com)
 * @license http://www.opensource.org/licenses/mit-license.php MIT
 */

 /**
  * class Scheme
  *
  * this is the model for terrecord
  *
  * @package terrecord
  */

abstract class Scheme
{
    /**
     * the TerRecord object (static)
     *
     * @access protected
     * @var TerRecord
     */
    protected static $terrecord = null;

    /**
     * the Scheme object (static)
     *
     * @access protected
     * @var Scheme
     */
    protected static $scheme= null;

    /**
     * informations of configuration
     *
     * @access protected
     * @var array
     */
    protected $config = null;

    /**
     * the data of scheme as output of this class
     *
     * this is created from the table data
     *
     * @access protected
     * @var array
     */
    protected $schemedata = array();

    /**
     * the table structure
     *
     * this is created from the table data
     *
     * @access protected
     * @var array
     */
    protected $tabledef = array();

    /**
     * the field structure
     *
     * this is created from the table data
     *
     * @access protected
     * @var array
     */
    protected $feilddef = array();

    /**
     * the primary key structure
     *
     * this is created from the table data
     *
     * @access protected
     * @var array
     */
    protected $pkeydef = array();

    /**
     * the index structure
     *
     * this is created from the table data
     *
     * @access protected
     * @var array
     */
    protected $indexdef = array();

    /**
     * the database connection
     *
     * @access protected
     * @var PDO
     */
    protected $db = null;

    /**
     * constructor
     *
     * @access public
     */
    public function __construct() {
        $this->terrecord = TerRecord::getInstance();
        if(!is_null($this->terrecord)) {
            $this->config = $this->terrecord->getConfig('db');
        }
        $this->connect();
    }

    /**
     * destructor
     *
     * @access public
     */
    public function __destruct() {
    }

    /**
     * disallow clonning (singleton)
     *
     * @throw RuntimeException
     */
    public final function __clone() {
        throw new EuntimeException(sprintf("Clonning is not allowed against %s.",get_class($this)));
    }

    /**
     * abstract methods
     */
    abstract protected static function getInstance();
    abstract protected function connect();
    abstract protected function getTableDef();
    abstract protected function getFieldDef();
    abstract protected function getPkeyDef();
    abstract protected function getIndexDef();
    abstract protected function convertType($type);
    abstract protected function convertSubtype($phptype,$subtyp);
    abstract protected function getDefaultValue($phptype,$type,$default);

    /**
     * create scheme data
     *
     * @access public
     * @return array the scheme data
     */
    public function createSchemeData() {
        $this->getTableDef();
        $this->getFieldDef();
        $this->getPkeyDef();
        $this->getIndexDef();
        
        if(!count($this->tabledef)) {
            return;
        }

        $setting = $this->terrecord->getConfig('setting');

        foreach($this->tabledef as $key => $table) {
            $class = array(
                'name'=>'',
                'desc'=>'',
                'type'=>'',
                'super'=>'',
                'author'=>$setting['author'],
                'copyright'=>$setting['copyright'],
                'package'=>$setting['package'],
                'license'=>$setting['license'],
                'version'=>$setting['version'],
                'see'=>array(),
                'namespace'=>$setting['namespace'],
                'table'=>'',
                'pkFields'=>'',
                'orderBy'=>'',
                'hasList'=>false,
                'hasCreated'=>false,
                'hasModified'=>false,
                'children'=>array(),
                'parents'=>array(),
                'params'=>array(),
            );

            // get parent class
            $this->getParentTable($key, $table, $class);

            // class information
            $this->createClassInformation($key, $table, $class);
    
            // get primary key
            $this->getPrimaryKey($key, $table, $class);
    
            // find order field
            $this->findOrderField($key, $table, $class);
    
            // fields
            $this->createParameterFromField($key, $table, $class);
    
            if(!$class['name']) {
                $this->schemedata[] = $class;
            } else {
                $this->schemedata[$class['name']] = $class;
            }
        }

        // set parent & children class
        $this->setParentChildrenClass();
        
        // show scheme data
        //echo print_r($this->schemedata,true)."\n";

        return $this->schemedata;
    }

    /**
     * get parent class
     *
     * @access private
     */
    private function getParentTable($key, $table, &$class) {
        $parents = array();
        foreach ($this->indexdef[$key] as $index) {
            if (strlen($index['REFERENCED_TABLE_NAME'])) {
                if (isset($parents[$index['REFERENCED_TABLE_NAME']])) {
                    array_push($parents[$index['REFERENCED_TABLE_NAME']], $index['COLUMN_NAME']);
                } else {
                    $parents[$index['REFERENCED_TABLE_NAME']] = array($index['COLUMN_NAME']);
                }
            }
        }
        $class['parents'] = $parents;
    }

    /**
     * create class information
     *
     * @access private
     */
    private function createClassInformation($key, $table, &$class) {
        if(mb_ereg("\[class ([^\]]*)\]",$table['Comment'],$regs)) {
            $class['name'] = $regs[1];
        }
        
        if(mb_ereg("\[desc ([^\]]*)\]",$table['Comment'],$regs)) {
            $class['desc'] = $regs[1];
        } else {
            $class['desc'] = '';
        }
        
        if(mb_ereg("\[type ([^\]\s]*)\]",$table['Comment'],$regs)) {
            $class['type'] = $regs[1];
            $class['super'] = '';
        } elseif(mb_ereg("\[type VE ([^\]]*)\]",$table['Comment'],$regs)) {
            $class['type'] = 'VE';
            $class['super'] = $regs[1];
        } else {
            $class['type'] = '';
            $class['super'] = '';
        }
        
        if ($class['type'] == 'R' OR
            $class['type'] == 'E') {
            $class['hasList'] = true;
        }
    
        $class['table'] = $table['Name'];
    }

    /**
     * get primary keys
     *
     * @access private
     */
    private function getPrimaryKey($key, $table, &$class) {
        if (count($this->pkeydef[$key])) {
            $pkfields = array();
            foreach ($this->pkeydef[$key] as $pkfield) {
                $pkfields[$pkfield['Column']] = $pkfield['Column'];
            }
            $class['pkFields'] = $pkfields;
        }
    }

    /**
     * find order field
     *
     * @access private
     */
    private function findOrderField($key, $table, &$class) {
        if(mb_ereg("\[order ([^\]]*)\]",$table['Comment'],$regs)) {
            $class['orderBy'] = $regs[1];
        } else {
            // if not exist specify about order, look up 'created' field
            foreach($this->fielddef[$key] as $field) {
                if ($class['orderBy'] == '' and $field['Field'] == 'created') {
                    $class['orderBy'] = 'created DESC';
                }
            }
        }
    }

    /**
     * create field
     *
     * @access private
     */
    private function createParameterFromField($key, $table, &$class) {
        $params = array();
        foreach($this->fielddef[$key] as $field) {
            $this->pickupParameter($field,$params,$class);            
        }
        $class['params'] = $params;
    }
    
    /**
     * pick up parameters from fields
     *
     * @access private
     * @return boolean
     */
    private function pickupParameter($field, &$params, &$class)
    {
        $temp = array();
        if (mb_ereg("\[member ([^\]]*)\]",$field["Comment"],$regs)) {
            $temp["fname"] = $regs[1];
        } else {
            return false;
        }
        $temp['fname'] = strtoupper(substr($temp['fname'], 0, 1)).substr($temp['fname'],1);
        $temp['mname'] = strtolower(substr($temp['fname'], 0, 1)).substr($temp['fname'],1);
    
        $temp["name"] = $field["Field"];
        $temp["dbtype"] = $field["Type"];
        $temp["type"] = $this->convertType($field["Type"]);
        $temp["subtype"] = $this->convertSubtype($temp["type"],($this->config['type']=='psql')?$field["subtype"]:$temp['dbtype']);
        $temp["default"] = $this->getDefaultValue($temp["type"],$field["Type"],$field["Default"]);
        $temp["primary"] = false;

        if (in_array($temp['name'], $class['pkFields'])) {
            $temp["primary"] = true;
        }

        $temp["desc"] = "";
        if (mb_ereg("\[desc ([^\]]*)\]", $field["Comment"], $regs)) {
            $temp["desc"] = $regs[1];
        }
        
        $temp["sequence"] = "";
        if(mb_ereg("\[sequence ([^\]]*)\]",$field["Comment"],$regs)) {
            $temp["sequence"] = $regs[1];
        }

        $temp["regexp"] = "";
        if(mb_ereg("\[regexp \"(.+)\"\]",$field["Comment"],$regs)) {
            $temp["regexp"] = $regs[1];
        }

        $temp["setter"] = true;
        if ($temp["sequence"] != "") {
            $temp["setter"] = false;
        }

        $temp["getter"] = true;
        if (mb_ereg("\[type ([^\]]*)\]", $field["Comment"], $regs)) {
            if ($regs[1] == 'Created') {
                $temp["setter"] = false;
                $class['hasCreated'] = true;
            }
            if ($regs[1] == 'Modified') {
                $temp["setter"] = false;
                $class['hasModified'] = true;
            }
        }
        
        $temp["pair"] = "";
        if(mb_ereg("\[pair ([^\]]*)\]",$field["Comment"],$regs)) {
            $temp["pair"] = $regs[1];
        }

        $params[] = $temp;
        return true;
    }

    /**
     * set parent & children class
     *
     * @access private
     */
    private function setParentChildrenClass() {
        $tmp_schemedata = $this->schemedata;
        
        // replace parents with primary key.
        foreach($this->schemedata as $index => $class) {
            $parents = array();
            $see = array();
            foreach ($class['parents'] as $parent=>$cols) {
                foreach($tmp_schemedata as $tmp_class) {
                    if ($tmp_class['table'] == $parent) {
                        $tmp = $tmp_class['pkFields'];
                        $tmp_cols = $cols;
                        $tmp2 = array();
                        foreach ($tmp as $key=>$val) {
                            $key = array_shift($tmp_cols);
                            $tmp2[$key] = $val;
                        }
                        $parents[$tmp_class['name']] = $tmp2;
                        $see[] = $tmp_class['name'];
                    }
                }
            }
            $this->schemedata[$index]['parents'] = $parents;
            $this->schemedata[$index]['see'] = $see;
        }

        // children
        foreach($this->schemedata as $index => $class) {
            foreach ($class['parents'] as $parent=>$cols) {
                foreach($tmp_schemedata as $tmp_class) {
                    if ($tmp_class['table'] == $this->schemedata[$parent]['table']) {
                        if ($class['type'] != 'TO' AND $class['type'] != 'TS' AND $class['type'] != 'TB') {
                            $tmp = $class['parents']; // children's parent def
                            $tmp2 = array();
                            foreach ($tmp as $key=>$val) {
                                if($key == $tmp_class['name']) {
                                    $tmp2 = $val;
                                }
                            }
                            if($class['name']) {
                                $this->schemedata[$tmp_class['name']]['children'][$class['name']] = $tmp2;
                                $this->schemedata[$tmp_class['name']]['see'][] = $class['name'];
                            } else {
                                $this->schemedata[$tmp_class['name']]['children'][$index] = $tmp2;
                            }
                        }
                    }
                }
            }
        }

        // relationships
        foreach($this->schemedata as $class) {
            if ($class['type'] == 'TO' OR $class['type'] == 'TS' OR $class['type'] == 'TB') {
                foreach ($class['parents'] as $parent=>$pkFields) {
                    if(!isset($this->schemedata[$parent]['relationships'])) {
                        $this->schemedata[$parent]['relationships'] = array();
                    }
                    // add parent to another parent list getter
                    foreach ($class['parents'] as $p=>$fs) {
                        if ($parent != $p) {
                            $type = 'List';
                            $mname = '';
                            foreach($fs as $k => $v) {
                                $name = $k;
                            }
                            foreach($class['params'] as $param) {
                                if($name == $param['name']) {
                                    $type = ($param['pair']=='N')?'List':'Class';
                                    break;
                                }
                            }

                            $this->schemedata[$parent]['relationships'][$p]= array(
                                'table' => $class['table'],
                                'myFields' => $pkFields,
                                'fields' => $fs,
                                'type' => $type
                            );
                        }
                    }
                }
            }
        }

        // rewrite relation key for parents, children and relations
        foreach($this->schemedata as $key => $class) {
            // parent
            foreach($class['parents'] as $k1 => $values) {
                foreach($values as $k2 => $value) {
                    foreach($class['params'] as $param) {
                        if($param['name']==$k2) {
                            unset($this->schemedata[$key]['parents'][$k1][$k2]);
                            $this->schemedata[$key]['parents'][$k1][$param['mname']] = $value;
                            break;
                        }
                    }
                }
            }
            // children
            foreach($class['children'] as $k1 => $values) {
                foreach($values as $k2 => $value) {
                    foreach($class['params'] as $param) {
                        if($param['name']==$value) {
                            $this->schemedata[$key]['children'][$k1][$k2] = $param['mname'];
                            break;
                        }
                    }
                }
            }
            // relations
            if(isset($class['relationships'])) {
            foreach($class['relationships'] as $k1 => $values) {
                foreach($values['myFields'] as $k2 => $value) {
                    foreach($class['params'] as $param) {
                        if($param['name']==$value) {
                            $this->schemedata[$key]['relationships'][$k1]['myFields'][$k2] = $param['mname'];
                            break;
                        }
                    }
                }
                foreach($values['fields'] as $k2 => $value) {
                    foreach($class['params'] as $param) {
                        if($param['name']==$value) {
                            $this->schemedata[$key]['relationships'][$k1]['fields'][$k2] = $param['mname'];
                            break;
                        }
                    }
                }
            }
            }
        }
    }
}
?>
