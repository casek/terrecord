    /**
     * the {$basename}Loader object (singleton)
     *
     * @var {$basename}Loader
     * @access protected
     */
    protected static $object = null;
    
    /**
     * get Instance (singleton)
     *
     * @access public
     * @return {$basename}Loader
     */
    public static function &getInstance() {ldelim}
        if (self::$object == null) {ldelim}
            self::$object = new {$basename}Loader();
        {rdelim}
        return self::object;
    {rdelim}
    
    /**
     * the SQL statement
     *
     * @var PDOStatement
     * @access protected
     */
    protected $stmt = null;
    
    /**
     * prepare sql statement
     *
     * @access protected
     * @param array $conditions an condition array
     * @param string $order order by clause
     * @param integer $limit limit clause
     * @param integer $offset offset clause
     * @param string $mode 'list' or 'count'
     * @return void
     * @throws RuntimeException
     * @throws PDOException
     */
    protected function createStmt($conditions, $order, $limit, $offset, $mode) {ldelim}
        // load from database
        $sql = 'SELECT ';
        if ($mode == 'list') {ldelim}
            $sql .= '*';
        {rdelim} else {ldelim}
            $sql .= 'count(*) AS cnt';
        {rdelim}
        $sql .= ' FROM {$table}';
        $where_mode = 'none';
        if (is_array($conditions)) {ldelim}
            if ($conditions == array_values($conditions)) {ldelim}
                if (count($conditions)) {ldelim}
                    $where = array_shift($conditions);
                    $sql .= ' WHERE '.$where;
                    $where_mode = 'list';
                {rdelim}
            {rdelim} else {ldelim}
                $sql .= ' WHERE true';
                foreach ($conditions as $key=>$val) {ldelim}
                    $sql .= ' AND '.$key.' = :'.$key;
                {rdelim}
                $where_mode = 'hash';
            {rdelim}
        {rdelim}
        if ($mode == 'list') {ldelim}
{if $orderBy}
            $orderBy = '{$orderBy}';
{else}
            $orderBy = null;
{/if}
            if (isset($order)) {ldelim}
                $orderBy = $order;
            {rdelim}
            if (isset($orderBy)) {ldelim}
                $sql .= ' ORDER BY '.$orderBy;
            {rdelim}
        {rdelim}
        if (isset($limit)) {ldelim}
            $sql .= ' LIMIT '.(int)$limit;
        {rdelim}
        if (isset($offset)) {ldelim}
            $sql .= ' OFFSET '.(int)$offset;
        {rdelim}
        Log::debug(sprintf(_('prepare sql in class %s, %s'), get_class($this), $sql));
        $this->stmt = $this->db->prepare($sql);
        if (is_array($conditions)) {ldelim}
            foreach ($conditions as $key=>$val) {ldelim}
                if ($where_mode == 'list') {ldelim}
                    $this->stmt->bindValue($key+1, $val);
                {rdelim} else {ldelim}
                    $this->stmt->bindValue(':'.$key, $val);
                {rdelim}
            {rdelim}
        {rdelim}
    {rdelim}
    
    /**
     * load {$name}List
     *
     * @access protected
     * @param array $conditions an condition array
     * @param string $order order by clause
     * @param integer $limit limit clause
     * @param integer $offset offset clause
     * @return {$name}
     * @throws RuntimeException
     * @throws PDOException
     */
    protected function loadTerList($conditions, $order, $limit, $offset) {ldelim}
        $this->createStmt($conditions, $order, $limit, $offset, 'list');
        $this->stmt->execute();
        
        $list = new {$basename}();
        $values = array();
        while ($row = $this->stmt->fetch()) {ldelim}
{foreach from=$params item=param}
{if $param.dbtype == 'timestamp' && $param.type == 'integer'}
            $values['{$param.mname}'] = ({$param.type})strtotime($row['{$param.name}']);
{else}
            $values['{$param.mname}'] = ({$param.type})$row['{$param.name}'];
{/if}
{/foreach}
            $list->add(new {$basename|replace:'List':''}($values));
        {rdelim}
        return $list;
    {rdelim}
    
    /**
     * count {$name}List
     *
     * @access protected
     * @param array $conditions an condition array
     * @param string $order order by clause
     * @param integer $limit limit clause
     * @param integer $offset offset clause
     * @return {$name}
     * @throws RuntimeException
     * @throws PDOException
     */
    protected function countTerList($conditions, $order, $limit, $offset) {ldelim}
        $this->createStmt($conditions, $order, $limit, $offset, 'count');
        $this->stmt->execute();
        $row = $this->stmt->fetch();
        return $row['cnt'];
    {rdelim}
