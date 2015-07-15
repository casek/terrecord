{include file="general/docblock.tpl"}
namespace {$namespace};
use Fuel\Core\Log;

{include file="general/class/docblock.tpl"}
abstract class TerList extends \Model
{ldelim}
    /**
     * array of object
     *
     * @var array
     * @access private
     */
    protected $items;
    
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
        return array('items'); 
    {rdelim}
    
    /**
     * wakeup
     *
     * @access public
     * @ignore
     */
    public function __wakeup() {ldelim}
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
     * @param integer $maxsize
     */
    public function __construct() {ldelim}
        $this->items = new \ArrayObject();
        Log::debug(sprintf(__("class %s was constructed."), get_class($this)));
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
     * add item
     *
     * @access public
     * @param TerRecord $item
     * @return void
     */
    public function add(TerRecord $item) {ldelim}
        $this->items[] = $item;
    {rdelim}
    
    /**
     * get number of list items
     *
     * @access public
     * @return integer
     */
    public function getLength() {ldelim}
        return $this->items->count();
    {rdelim}
    
    /**
     * get Iterator
     *
     * @access public
     * @return object ListIterator
     */
    public function getIterator() {ldelim}
        return $this->items->getIterator();
    {rdelim}
    
    /**
     * get list as array
     *
     * @access public
     * @return array
     */
    public function toArray() {ldelim}
        $tmp = array();
        $it = $this->items->getIterator();
        while ($it->valid()) {ldelim}
            $item = $it->current();
            $tmp[] = $item->toArray();
            $it->next();
        {rdelim}
        return $tmp;
    {rdelim}
    
    /**
     * get list as JSON
     *
     * @access public
     * @return string
     */
    public function toJSON() {ldelim}
        return json_encode($this->toArray());
    {rdelim}
{rdelim}
