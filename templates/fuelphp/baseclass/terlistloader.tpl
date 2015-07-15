{include file="general/docblock.tpl"}
namespace {$namespace};
use Fuel\Core\Log;

{include file="general/class/docblock.tpl"}
abstract class TerListLoader extends \Model {ldelim}
    /**
     * database object
     *
     * @var mixed
     * @access protected
     */
    protected $db;
    
    /**
     * call
     *
     * @access public
     * @ignore
     */
    public function __call($name, $arguments) {ldelim}
        throw new \BadMethodCallException(sprintf(__("Method '%s' is not found."), $name));
    {rdelim}
    
    /**
     * call static 
     *
     * @access public
     * @ignore
     */
    public static function __callStatic($name, $arguments) {ldelim}
        throw new \BadMethodCallException(sprintf(__("Method '%s' is not found."), $name));
    {rdelim}
    
    /**
     * isset
     *
     * @access public
     * @ignore
     */
    public function __isset($name) {ldelim}
        throw new \BadMethodCallException(sprintf(__("Member '%s' is not found."), $name));
    {rdelim}
    
    /**
     * unset
     *
     * @access public
     * @ignore
     */
    public function __unset($name) {ldelim}
        throw new \BadMethodCallException(sprintf(__("Member '%s' is not found."), $name));
    {rdelim}
    
    /**
     * constructor
     *
     * @access protected
     */
    protected function __construct() {ldelim}
        $this->connect();
        Log::debug(sprintf(_('class %s was constructed.'), get_class($this)));
    {rdelim}
    
    /**
     * destructor
     *
     * @access public
     */
    public function __destruct() {ldelim}
        Log::debug(sprintf(__("class %s was destructed."), get_class($this)));
    {rdelim}
    
    /**
     * connect
     *
     * @access private
     */
    private function connect() {ldelim}
        $connection = Connection::getInstance();
        $cons = $connection->getConnection();
        $this->db = $cons["readable"];
    {rdelim}
    
    /**
     * get Instance (singleton)
     *
     * @access public
     * @return TerListLoader
     */
    public static function &getInstance() {ldelim}{rdelim}
    
    /**
     * disallow clone (singleton)
     *
     * @throws RuntimeException
     */
    public final function __clone() {ldelim}
        throw new \RuntimeException(sprintf(_('Clone is not allowed against %s.'), get_class($this)));
    {rdelim}
    
    /**
     * load TerList
     *
     * @access public
     * @param array $conditions an condition array (option)
     * @param string $order order by clause (option)
     * @param integer $limit limit clause (option)
     * @param integer $offset offset clause (option)
     * @return TerList
     */
    public function load($conditions=array(), $order=null, $limit=null, $offset=null) {ldelim}
        return $this->loadTerList($conditions, $order, $limit, $offset);
    {rdelim}
    
    /**
     * count TerList
     *
     * @access public
     * @param array $conditions an condition array (option)
     * @param string $order order by clause (option)
     * @param integer $limit limit clause (option)
     * @param integer $offset offset clause (option)
     * @return integer
     */
    public function count($conditions=array(), $order=null, $limit=null, $offset=null) {ldelim}
        return $this->countTerList($conditions, $order, $limit, $offset);
    {rdelim}
    
    /**
     * load TerList (new here)
     *
     * @access protected
     * @param array $conditions an condition array
     * @param string $order order by clause
     * @param integer $limit limit clause
     * @param integer $offset offset clause
     * @return TerList
     * @throws RuntimeException
     */
    abstract protected function loadTerList($conditions, $order, $limit, $offset);
    
    /**
     * count TerList (new here)
     *
     * @access protected
     * @param array $conditions an condition array
     * @param string $order order by clause
     * @param integer $limit limit clause
     * @param integer $offset offset clause
     * @return integer
     * @throws RuntimeException
     */
    abstract protected function countTerList($conditions, $order, $limit, $offset);
{rdelim}
