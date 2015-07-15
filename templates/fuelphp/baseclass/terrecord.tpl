{include file="general/docblock.tpl"}
namespace {$namespace};
use Fuel\Core\Log;

{include file="general/class/docblock.tpl"}
abstract class TerRecord extends \Model implements \iterator
{ldelim}
    /**
     * readable database object
     *
     * @var mixed
     * @access protected
     */
    protected $rdb;
    
    /**
     * writable database object
     *
     * @var mixed
     * @access protected
     */
    protected $wdb;
    
    /**
     * loaded flag
     *
     * @var boolean
     * @access protected
     */
    protected $loaded;
    
    /**
     * changed flag
     *
     * @var boolean
     * @access protected
     */
    protected $changed;
    
    /**
     * properties
     * 
     * provides virtual properties
     *
     * @var array
     * @access protected
     */
    protected $properties;
    
    /**
     * current (iterator)
     *
     * @access public
     * @ignore
     */
    public function current() {ldelim}
        $var = current($this->properties);
        return $var ? $var['value'] : false;
    {rdelim}
    
    /**
     * key (iterator)
     *
     * @access public
     * @ignore
     */
    public function key() {ldelim}
        return key($this->properties);
    {rdelim}
    
    /**
     * next (iterator)
     *
     * @access public
     * @ignore
     */
    public function next() {ldelim}
        $var = next($this->properties);
        return $var ? $var['value'] : false;
    {rdelim}
    
    /**
     * rewind (iterator)
     *
     * @access public
     * @ignore
     */
    public function rewind() {ldelim}
        reset($this->properties);
    {rdelim}
    
    /**
     * valid (iterator)
     *
     * @access public
     * @ignore
     */
    public function valid() {ldelim}
        return ($this->current() !== false);
    {rdelim}
    
    /**
     * getter
     *
     * @access public
     * @ignore
     * @throws BadMethodCallException
     */
    public function __get($name) {ldelim}
        if (!array_key_exists($name, $this->properties)) {ldelim}
            throw new \BadMethodCallException(sprintf(__("Member '%s' is not found."), $name));
        {rdelim}    
        return $this->properties[$name]['value'];
    {rdelim}
    
    /**
     * setter
     *
     * @access public
     * @ignore
     * @throws BadMethodCallException
     */
    public function __set($name, $value) {ldelim}
        if (!array_key_exists($name, $this->properties)) {ldelim}
            throw new \BadMethodCallException(sprintf(__("Member '%s' is not found."), $name));
        {rdelim}
        
        if ($this->properties[$name]['value'] != $value) {ldelim}
            $this->properties[$name]['value'] = $value;
            $this->changed = true;
        {rdelim}
        return true;
    {rdelim}

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
     * sleep
     *
     * @access public
     * @ignore
     */
    public function __sleep() {ldelim}
        return array('rdb', 'wdb', 'loaded', 'changed', 'properties'); 
    {rdelim}
    
    /**
     * wakeup
     *
     * @access public
     * @ignore
     */
    public function __wakeup() {ldelim}
        $this->connect();
    {rdelim}
    
    /**
     * toString
     *
     * @access public
     * @ignore
     */
    public function __toString() {ldelim}
        return print_r($this->toArray(),true);
    {rdelim}
    
    /**
     * constructor
     *
     * @access public
     * @param array $values properties value of record
     */
    public function __construct($values = null) {ldelim}
        $this->connect();
        $this->loaded = false;
        $this->changed = false;
        if (is_array($values)) {ldelim}
            foreach ($values as $key=>$val) {ldelim}
                $this->properties[$key]['value'] = $val;
            {rdelim}
	        $this->loaded = true;
            Log::debug(sprintf(__("class %s was constructed with values (%s)"), get_class($this), implode(',', $values)));
        {rdelim} else {ldelim}
            Log::debug(sprintf(__("class %s was constructed."), get_class($this)));
        {rdelim}
    {rdelim}

    /**
     * connect
     *
     * @access private
     */
    private function connect() {ldelim}
        $connection = Connection::getInstance();
        $cons = $connection->getConnection();
        $this->rdb = $cons["readable"];
        $this->wdb = $cons["writable"];
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
     * save
     *
     * @access public
     * @return boolean
     */
    abstract public function save();
    
    /**
     * delete
     *
     * @access public
     * @return boolean
     */
    abstract public function delete();
    
    /**
     * setDefault
     *
     * @access protected
     * @return void
     */
    protected function setDefault() {ldelim}
        foreach($this->properties as $key=>$prop) {ldelim}
            $this->properties[$key]['value'] = $this->properties[$key]['defalutvalue'];
        {rdelim}
        $this->loaded = false;
        $this->changed = false;
    {rdelim}
    
    /**
     * get loaded flag
     * 
     * @access public
     * @return boolean
     */
    public function isLoaded() {ldelim}
        return $this->loaded;
    {rdelim}
        
    /**
     * get changed flag
     * 
     * @access public
     * @return boolean
     */
    public function isChanged() {ldelim}
        return $this->changed;
    {rdelim}

    /**
     * object to Array
     *
     * @access public
     * @return array
     */
    public function toArray() {ldelim}
        $ret = array();
        foreach($this->properties as $key=>$prop) {ldelim}
            $ret[$key] = $prop['value'];
        {rdelim}
        return $ret;
    {rdelim}
    
    /**
     * toJSON
     *
     * @access public
     * @return string
     */
    public function toJSON() {ldelim}
        return json_encode($this->toArray());
    {rdelim}
    
    /**
     * get current timestamp from database
     *
     * @access protected
     * @return integer UNIX timestamp
     */
    protected function getCurrentTimestamp() {ldelim}
{if $db_type == 'psql'}
        $sql = 'SELECT EXTRACT(EPOCH FROM CURRENT_TIMESTAMP(0))';
{else if $db_type =='mysql'}
        $sql = 'SELECT UNIX_TIMESTAMP()';
{/if}
        $stmt = $this->rdb->prepare($sql);
        $stmt->execute();
        return $stmt->fetchColumn();
    {rdelim}
{rdelim}
