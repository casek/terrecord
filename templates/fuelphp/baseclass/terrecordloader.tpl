{include file="general/docblock.tpl"}
namespace {$namespace};
use Fuel\Core\Log;

{include file="general/class/docblock.tpl"}
abstract class TerRecordLoader extends \Model
{ldelim}
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
     * load TerRecord
     *
     * @access public
     * @param array $keys an array for idenfity record
     * @return TerRecord
     */
    public function load($keys) {ldelim}
        return $this->loadTerRecord($keys);
    {rdelim}
    
    /**
     * load TerRecord (new here)
     *
     * @access protected
     * @param array $keys an array for idenfity record
     * @return TerRecord
     * @throws RuntimeException
     */
    abstract protected function loadTerRecord($keys);
{rdelim}
