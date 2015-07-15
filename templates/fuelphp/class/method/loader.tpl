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
            self::$object = new {$classname}();
        {rdelim}
        return self::$object;
    {rdelim}
    
    /**
     * the PDOStatement for SQL SELECT
     *
     * @var PDOStatement
     * @access protected
     */
    protected $stmt = null;
    
    /**
     * load {$basename}
     *
     * @access protected
     * @param array $keys an array for idenfity record
     * @return {$basename}
     * @throws RuntimeException
     * @throws PDOException
     */
    protected function loadTerRecord($keys) {ldelim}
        // check $keys
        if (!is_array($keys)) {ldelim}
            $keys = array($keys);
        {rdelim}
        if (count($keys) != {$pkFields|@count}) {ldelim}
            throw new \RuntimeException(sprintf(_('Parameter $key must be an array of %s counts.'), {$pkFields|@count}));
        {rdelim}
        
        // load from database
        if (!isset($this->stmt)) {ldelim}
            $sql = 'SELECT * FROM {$table}';
{foreach $pkFields as $fname => $mname}
{if $mname@first}
            $sql .= ' WHERE {$fname} = :{$fname}';
{else}
            $sql .= ' AND {$fname} = :{$fname}';
{/if}
{/foreach}
            Log::debug(sprintf(_('prepare sql in class %s, %s'), get_class($this), $sql));
            $this->stmt = $this->db->prepare($sql);
        {rdelim}
{foreach $pkFields as $fname => $mname}
        $this->stmt->bindValue(':{$fname}', $keys[{$mname@index}]);
{/foreach}
        $this->stmt->execute();
        
        $values = array();
        if ($row = $this->stmt->fetch()) {ldelim}
{foreach $params as $param}
{if $param.dbtype == 'timestamp' && $param.type == 'integer'}
            $values['{$param.mname}'] = ({$param.type})strtotime($row['{$param.name}']);
{else}
            $values['{$param.mname}'] = ({$param.type})$row['{$param.name}'];
{/if}
{/foreach}
            Log::debug(sprintf(_('record was found in class %s with keys (%s)'), get_class($this), implode(',', $keys)));
        {rdelim} else {ldelim}
            // new 'new record' when not found
            $values = null;
            Log::debug(sprintf(_('record was not found in class %s with keys (%s)'), get_class($this), implode(',', $keys)));
        {rdelim}
        
        return new {$basename}($values);
    {rdelim}
