{include file="general/docblock.tpl"}
namespace {$namespace};
use Fuel\Core\Database_Connection;
use Fuel\Core\Log;

{include file="general/class/docblock.tpl"}
class Connection
{ldelim}
    /**
     * the connection object (static)
     *
     * @var Connection
     * @access private
     */
    private static $obj = null;

    /**
     * the PDO database object for read
     *
     * @var PDO
     * @access private
     */
    private $rdb = null;

    /**
     * the PDO database object for write
     *
     * @var PDO
     * @access private
     */
    private $wdb = null;

    /**
     * setting array (cache)
     *
     * @var array
     * @access private
     */
    private $settings = array();

    /**
     * constructor
     *
     * @access private
     */
    private function __construct() {ldelim}
        $dbconn = Database_Connection::instance("readable");   
        if (is_null($dbconn->connection())) {ldelim}
            $dbconn->connect();
        {rdelim}
        $this->rdb = $dbconn->connection();

        // the same database between readable and writable?
        $config = \Config::get("db");
        if($config["readable"] === $config["writable"] &&
           $config["readable"]["connection"] === $config["writable"]["connection"]) {ldelim}
            $this->wdb = $this->rdb;
        {rdelim} else {ldelim}
            $dbconn = Database_Connection::instance("writable");
            if (is_null($dbconn->connection())) {ldelim}
                $dbconn->connect();
            {rdelim}
            $this->wdb = $dbconn->connection();
        {rdelim}
    {rdelim}

    /**
     * disallow clone (singleton)
     *
     * @throws RuntimeException
     */
    public final function __clone() {ldelim}
        throw new \RuntimeException(sprintf(__("Clone is not allowed against %s.")),get_class($this));
    {rdelim}

    /**
     * get instance (singleton)
     *
     * @return Connection
     */
    public static function getInstance() {ldelim}
        if(Connection::$obj == null) {ldelim}
            Connection::$obj = new Connection();
        {rdelim}
        return Connection::$obj;
    {rdelim}

    /**
     * get connection to database
     *
     * @access public
     * return Array
     */
    public function getConnection() {ldelim}
        return array("readable"=>$this->rdb, "writable"=>$this->wdb);
    {rdelim}
{rdelim}
