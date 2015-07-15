<?php
/**
 * framework.php
 *
 * this is the base class about framework
 *
 * @author Keisuke Mutoh <kmutoh@lefthandle.com>
 * @version 1.0
 * @package terrecord
 * @copyright Team Left Handle (http://lefthandle.com)
 * @license http://www.opensource.org/licenses/mit-license.php MIT
 */

 /**
  * class Framework
  *
  * this is the base class about framework
  *
  * @package terrecord
  */

abstract class Framework
{
    /**
     * the TerRecord object (static)
     *
     * @access protected
     * @var TerRecord
     */
    protected static $terrecord = null;

    /**
     * the Framework object (static)
     *
     * @access protected
     * @var Scheme
     */
    protected static $framework= null;

    /**
     * informations of configuration
     *
     * @access protected
     * @var array
     */
    protected $config = null;

    /**
     * smarty object
     *
     * @access protected
     * @var Smarty
     */
    protected $smarty = null;

    /**
     * scheme data
     *
     * @access protected
     * @var array
     */
    protected $scheme = null;

    /**
     * constructor
     *
     * @access public
     */
    public function __construct($scheme=array()) {
        $this->terrecord = TerRecord::getInstance();
        if(!is_null($this->terrecord)) {
            $this->config = $this->terrecord->getConfig('framework');
        }

        $this->scheme = $scheme;

        require_once 'smarty3/Smarty.class.php';
        $this->smarty = new Smarty();

        $this->smarty->template_dir = getcwd().'/templates/';
        $this->smarty->compile_dir = getcwd().'/templates/templates_c/';
        $this->smarty->cache_dir = getcwd().'/templates/cache/';
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
    abstract protected function createBaseClasses();
    abstract protected function createClasses();
}
?>
