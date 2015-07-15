{foreach $target.children as $child => $fields}
{if $schemes[$child].type == 'VE'}
    /**
     * get {$child} object (as child)
     *
     * @access public
     * @return {$child}
     */
    public function get{$child}() {ldelim}
        $loader =& {$child}Loader::getInstance();
        return $loader->load(array({foreach $fields as $fname => $mname}{if $mname@iteration gt 1}, {/if}$this->properties['{$mname}']['value']{/foreach}));
    {rdelim}

{elseif $schemes[$child].type == 'R' || $schemes[$child].type == 'E'}
    /**
     * get {$child}List object (as children)
     *
     * @access public
     * @return {$child}List
     */
    public function get{$child}List() {ldelim}
        $loader =& {$child}ListLoader::getInstance();
        return $loader->load(array(
{foreach $fields as $fname => $mname}
            '{$fname}'=>$this->properties['{$mname}']['value']
{/foreach}
        ));
    {rdelim}
    
    /**
     * get {$child}Count (as children)
     *
     * @access public
     * @return integer
     */
    public function get{$child}Count() {ldelim}
        $loader =& {$child}ListLoader::getInstance();
        return $loader->count(array(
{foreach $fields as $fname => $mname}
            '{$fname}'=>$this->properties['{$mname}']['value']
{/foreach}
        ));
    {rdelim}

{elseif $schemes[$child].type == 'MO'}
    /**
     * {$schemes[$child].name} values
     *
     * @var array
     * @access protected
     */
    protected $settings = array();

    /**
     * set {$schemes[$child].name} 
     *
     * @access public
     * @param string $key
     * @param string $subkey
     * @param mixed $value
     * @return boolean
     */
    public function set{$schemes[$child].name}($key, $subkey, $value) {ldelim}
        if(!$subkey) {ldelim}
            if (isset($this->settings[$key]) AND
                $this->settings[$key] === $value) {ldelim}
                return true;
            {rdelim}
        {rdelim} else {ldelim}
            if(isset($this->settings[$key][$subkey]) AND
               $this->settings[$key][$subkey] === $value) {ldelim}
                return true;
            {rdelim}
        {rdelim}
        
        if (is_null($value)) {ldelim}
            $sql = 'DELETE FROM {$schemes[$child].table}';
            $sql .= ' WHERE user_id = :userid AND setting_key = :key';
            if($subkey) {ldelim}
                $sql .= " AND setting_subkey = :subkey";
            {rdelim}
            $stmt = $this->wdb->prepare($sql);
            $stmt->bindParam(':userid', $this->properties['id']['value']);
            $stmt->bindParam(':key', $key);
            if($subkey) {ldelim}
                $stmt->bindParam(':subkey', $subkey);
            {rdelim}
            $stmt->execute();
            if ($stmt->rowCount() == 1) {ldelim}
                if(!$subkey) {ldelim}
                    unset($this->settings[$key]);
                {rdelim} else {ldelim}
                    unset($this->settings[$key][$subkey]);
                {rdelim}
                return true;
            {rdelim}
            return false;
        {rdelim}

        $setting_value = is_array($value) ? var_export($value, true) : $value;
        
        $sql = 'UPDATE {$schemes[$child].table}';
        $sql .= ' SET setting_value = :setting_value';
        $sql .= ', modified = CURRENT_TIMESTAMP';
        $sql .= ' WHERE user_id = :userid AND setting_key = :key';
        if($subkey) {ldelim}
            $sql .= " AND setting_subkey = :subkey";
        {rdelim}
        $stmt = $this->wdb->prepare($sql);
        $stmt->bindParam(':userid', $this->properties['id']['value']);
        $stmt->bindParam(':key', $key);
        if($subkey) {ldelim}
            $stmt->bindParam(':subkey', $subkey);
        {rdelim}
        $stmt->bindParam(':setting_value', $setting_value);
        $stmt->execute();
        if ($stmt->rowCount() != 1) {ldelim}
            $time = $this->getCurrentTimestamp();
            
            $sql = 'INSERT INTO {$schemes[$child].table} (';
            $sql .= ' user_id,';
            $sql .= ' setting_key,';
            if($subkey) {ldelim}
                $sql .= ' setting_subkey,';
            {rdelim}
            $sql .= ' setting_value,';
            $sql .= ' created,';
            $sql .= ' modified';
            $sql .= ') VALUES (';
            $sql .= ' :userid,';
            $sql .= ' :key,';
            if($subkey) {ldelim}
                $sql .= ' :subkey,';
            {rdelim}
            $sql .= ' :setting_value,';
            $sql .= ' :created,';
            $sql .= ' :modified';
            $sql .= ')';
            $stmt = $this->wdb->prepare($sql);
            $stmt->bindParam(':userid', $this->properties['id']['value']);
            $stmt->bindParam(':key', $key);
            if($subkey) {ldelim}
                $stmt->bindParam(':subkey', $subkey);
            {rdelim}
            $stmt->bindParam(':setting_value', $setting_value);
            $stmt->bindValue(':created', date("Y-m-d H:i:s", $time));
            $stmt->bindValue(':modified', date("Y-m-d H:i:s", $time));
            $stmt->execute();
            if ($stmt->rowCount() != 1) {ldelim}
                return false;
            {rdelim}
        {rdelim}
        if(!$subkey) {ldelim}
            $this->settings[$key] = $value;
        {rdelim} else {ldelim}
            $this->settings[$key][$subkey] = $value;
        {rdelim}
        return true;
    {rdelim}
    
    /**
     * get setting from the database (or cache)
     *
     * @access public
     * @param string $key setting key
     * @param string $subkey setting subkey
     * @return mixed setting value
     */
    public function getSetting($key,$subkey='') {ldelim}
        $value = null;
        if (!$subkey && isset($this->settings[$key])) {ldelim}
            $value = $this->settings[$key];
        {rdelim} else if($subkey && isset($this->settings[$key][$subkey])) {ldelim}
            $value = $this->settings[$key][$subkey];
        {rdelim} else {ldelim}
            $sql = 'SELECT setting_value';
            $sql .= ' FROM {$schemes[$child].table}';
            $sql .= ' WHERE user_id = :userid AND setting_key = :setting_key';
            if($subkey) {ldelim}
                $sql .= " AND setting_subkey = :subkey";
            {rdelim}
            $stmt = $this->rdb->prepare($sql);
            $stmt->bindParam(':userid', $this->properties['id']['value']);
            $stmt->bindParam(':setting_key', $key);
            if($subkey) {ldelim}
                $stmt->bindParam(':subkey', $subkey);
            {rdelim}
            $stmt->execute();
            if ($row = $stmt->fetch()) {ldelim}
                $value = $row['setting_value'];
                if (substr($value,0,7) == 'array (' and substr($value,-1) == ')') {
                    eval('$value = '.$row['setting_value'].';');
                }
            {rdelim}
            if(!$subkey) {ldelim}
                $this->settings[$key] = $value;
            {rdelim} else {ldelim}
                $this->settings[$key][$subkey] = $value;
            {rdelim}
        {rdelim}
        return $value;
    {rdelim}

    /**
     * get setting list from the database (or cache)
     *
     * @access public
     * @return array
     */
    public function getSettingList() {ldelim}
        $sql = 'SELECT *';
        $sql .= ' FROM {$schemes[$child].table}';
        $sql .= ' WHERE user_id = :userid';
        $stmt = $this->rdb->prepare($sql);
        $stmt->bindParam(':userid', $this->properties['id']['value']);
        $stmt->execute();
        return $stmt->fetchAll();
    {rdelim}

{/if}
{/foreach}
