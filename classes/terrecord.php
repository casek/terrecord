<?php
/**
 * terrecord.php
 *
 * this is including main class of terrecord
 *
 * @author Keisuke Mutoh <kmutoh@lefthandle.com>
 * @version 1.0
 * @package terrecord
 * @copyright Team Left Handle (http://lefthandle.com)
 * @license http://www.opensource.org/licenses/mit-license.php MIT
 */

 /**
  * class TerRecord
  *
  * this is main module for terrecord
  *
  * @package terrecord
  */

class TerRecord
{
    /**
     * the TerRecord object (static)
     *
     * @access private
     * @var TerRecord
     */
    private static $terrecord = null;

    /**
     * properties
     *
     * @access protected
     * @var array
     */
    protected $properties = array(

    );

    /**
     * informations of configuration
     *
     * @access private
     * @var array
     */
    private $config = null;

    /**
     * system name
     *
     * @access private
     * @var string
     */
    private $system_name = "";

    /**
     * logger
     *
     * @access private
     * @var Pear::Log
     */
    private $logger = null;

    /**
     * getter 
     * 
     * @access public
     * @ignore
     * @throw BadMethodCallException
     */
    public function __get($name) {
        if(!array_key_exists($name, $this->properties)) {
            throw new BadMethodCallException(sprintf("Member '%s' is not found.", $name));
        }
        return $this->properties[$name]['value'];
    }

    /**
     * setter 
     * 
     * @access public
     * @ignore
     * @throw BadMethodCallException
     */
    public function __set($name, $value) {
        if(!array_key_exists($name, $this->properties)) {
            throw new BadMethodCallException(sprintf("Member '%s' is not found.", $name));
        }

        if($this->properties[$name]['value'] != $value) {
            $this->properties[$name]['value'] = $value;
        }
        return;
    }

    /**
     * constructor
     *
     * @access public
     */
    public function __construct($config="config.ini") {
        // read configuration file
        $this->config = array();
        if(file_exists($config)) {
            $this->config = parse_ini_file($config,true);
        } else {
            throw new Exception("Can't find configuration file...");
        }
        
        // set system name;
        $this->system_name = $this->config['setting']['slug'];

        // create logger by PEAR::Log
        require_once 'Log.php';
        eval("\$level = ".$this->config['debug']['level'].";");
        switch($this->config['debug']['type']) {
        case 'none':
            break;
        case 'stdout':
            $this->logger =& Log::factory('console','',$this->system_name); 
            break;
        default:
            $this->logger =& Log::factory('file',$this->config['debug']['type'],$this->system_name);
        }
        if(!is_null($this->logger)) {
            $this->logger->setMask(Log::UPTO($level));
        }
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
     * get instance (singleton)
     *
     * @access public
     * @param string $config configuration file's name
     * @return TerRecord
     */
    public static function getInstance($config="config.ini") {
        if(TerRecord::$terrecord == null) {
            TerRecord::$terrecord = new TerRecord($config);
        }
        return TerRecord::$terrecord;
    }

    /**
     * do logging
     *
     * @access public
     * @param string $message the message
     */
    public function log($message) {
        eval("\$level = ".$this->config['debug']['level'].";");
        if($level=="") {
            $level = PEAR_LOG_DEBUG;
        }
        $this->logger->log($message,$level);
    }

    /**
     * get configuration data
     *
     * @access public
     * @param string $key the key of configuration data (default '')
     * @return mix
     */
    public function getConfig($key='',$subkey='') {
        if($key=='') {
            return $this->config;
        } else {
            if(!array_key_exists($key, $this->config)) {
                throw new BadMethodCallException(sprintf("Member '%s' is not found.", $key));
            }
            if($subkey=='') {
                return $this->config[$key];
            } else {
                if(!array_key_exists($subkey, $this->config[$key])) {
                    throw new BadMethodCallException(sprintf("Member '%s' is not found.", $subkey));
                }
                return $this->config[$key][$subkey];
            }
        }
    }
}
?>
