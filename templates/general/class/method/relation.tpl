{foreach $relationships as $relname => $rel}
{if $rel.type == 'List'}
    /**
     * get {$relname}List (as relationships)
     *
     * @access public
     * @return {$relname}List
     */
    public function get{$relname}List() {ldelim}
        $ret = new {$relname}List();
        
{foreach $rel.fields as $fname => $mname}
{if $mname@iteration == 1}
        $sql = 'SELECT {$fname}';
{else}
        $sql .= ', {$fname}';
{/if}
{/foreach}
        $sql .= ' FROM {$rel.table}';
{foreach $rel.myFields as $fname => $mname}
        $sql .= ' {if $mname@first}WHERE {else}AND {/if}{$fname} = :{$fname}';
{/foreach}
        $stmt = $this->rdb->prepare($sql);
{foreach $rel.myFields as $fname => $mname}
        $stmt->bindParam(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
        $stmt->execute();
        
        $loader =& {$relname}Loader::getInstance();
        while ($row = $stmt->fetch()) {ldelim}
            $ret->add($loader->load(array({foreach $rel.fields as $fname => $mname}{if $mname@iteration > 1}, {/if}$row['{$fname}']{/foreach})));
        {rdelim}
        
        return $ret;
    {rdelim}
    
    /**
     * get {$relname}Count (as relationships)
     *
     * @access public
     * @return integer
     */
    public function get{$relname}Count() {ldelim}
        $ret = 0;
        
{foreach $rel.fields as $fname => $mname}
{if $mname@iteration == 1}
        $sql = 'SELECT {$fname}';
{else}
        $sql .= ', {$fname}';
{/if}
{/foreach}
        $sql .= ' FROM {$rel.table}';
{foreach $rel.myFields as $fname => $mname}
        $sql .= ' {if $mname@first}WHERE {else}AND {/if}{$fname} = :{$fname}';
{/foreach}
        $stmt = $this->rdb->prepare($sql);
{foreach $rel.myFields as $fname => $mname}
        $stmt->bindParam(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
        $stmt->execute();
        
        $loader =& {$relname}Loader::getInstance();
        $ret = $stmt->rowCount();
        
        return $ret;
    {rdelim}
    
    /**
     * add {$relname} (as relationships)
     *
     * @access public
     * @param {$relname} ${$relname|lower}
     * @return boolean
     */
    public function add{$relname}({$relname} ${$relname|lower}) {ldelim}
        $sql = 'INSERT INTO {$rel.table} (';
{foreach $rel.myFields as $fname => $mname}
{if $mname@iteration == 1}
        $sql .= ' {$fname}';
{else}
        $sql .= ', {$fname}';
{/if}
{/foreach}
{foreach $rel.fields as $fname => $mname}
        $sql .= ', {$fname}';
{/foreach}
        $sql .= ') VALUES (';
{foreach $rel.myFields as $fname => $mname}
{if $mname@iteration == 1}
        $sql .= ' :{$fname}';
{else}
        $sql .= ', :{$fname}';
{/if}
{/foreach}
{foreach $rel.fields as $fname => $mname}
        $sql .= ', :{$fname}';
{/foreach}
        $sql .= ')';
        $stmt = $this->wdb->prepare($sql);
{foreach $rel.myFields as $fname => $mname}
        $stmt->bindParam(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
{foreach $rel.fields as $fname => $mname}
        $stmt->bindValue(':{$fname}', ${$relname|lower}->{$mname});
{/foreach}
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) {ldelim}
            return false;
        {rdelim}
        
        return true;
    {rdelim}
    
    /**
     * remove {$relname} (as relationships)
     *
     * @access public
     * @param {$relname} ${$relname|lower}
     * @return boolean
     */
    public function remove{$relname}({$relname} ${$relname|lower}) {ldelim}
        $sql = 'DELETE FROM {$rel.table}';
{foreach $rel.myFields as $fname => $mname}
{if $mname@iteration == 1}
        $sql .= ' WHERE {$fname} = :{$fname}';
{else}
        $sql .= ' AND {$fname} = :{$fname}';
{/if}
{/foreach}
{foreach $rel.fields as $fname => $mname}
        $sql .= ' AND {$fname} = :{$fname}';
{/foreach}
        $stmt = $this->wdb->prepare($sql);
{foreach $rel.myFields as $fname => $mname}
        $stmt->bindValue(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
{foreach $rel.fields as $fname => $mname}
        $stmt->bindValue(':{$fname}', ${$relname|lower}->{$mname});
{/foreach}
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) {ldelim}
            return false;
        {rdelim}
        
        return true;
    {rdelim}

{else}    
    /**
     * get {$relname} (as relationship)
     *
     * @access public
     * @return {$relname}
     */
    public function get{$relname}() {ldelim}
        $ret = new {$relname}();
        
{foreach $rel.fields as $fname => $mname}
{if $mname@iteration == 1}
        $sql = 'SELECT {$fname}';
{else}
        $sql .= ', {$fname}';
{/if}
{/foreach}
        $sql .= ' FROM {$rel.table}';
{foreach $rel.myFields as $fname => $mname}
        $sql .= ' {if $mname@iteration == 1}WHERE {else}AND {/if}{$fname} = :{$fname}';
{/foreach}
        $stmt = $this->rdb->prepare($sql);
{foreach $rel.myFields as $fname => $mname}
        $stmt->bindParam(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
        $stmt->execute();
        
        if ($row = $stmt->fetch()) {ldelim}
            $loader =& {$relname}Loader::getInstance();
            $ret = $loader->load(array({foreach $rel.fields as $fname => $mname}{if $mname@iteration > 1}, {/if}$row['{$fname}']{/foreach}));
        {rdelim}
        
        return $ret;
    {rdelim}
    
    /**
     * set {$relname} (as relationship)
     *
     * @access public
     * @param {$relname} ${$relname|lower}
     * @return boolean
     * @throws PDOException
     */
    public function set{$relname}({$relname} ${$relname|lower}) {ldelim}
        // do update
        $sql = 'UPDATE {$rel.table}';
{foreach $rel.fields as $fname => $mname}
{if $mname@first}
        $sql .= ' SET {$fname} = :{$fname}';
{else}
        $sql .= ', {$fname} = :{$fname}';
{/if}
{/foreach}
{foreach $rel.myFields as $fname => $mname}
        $sql .= ' {if $mname@iteration == 1}WHERE {else}AND {/if}{$fname} = :{$fname}';
{/foreach}
        $stmt = $this->wdb->prepare($sql);
{foreach $rel.myFields as $fname => $mname}
        $stmt->bindParam(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
{foreach $rel.fields as $fname => $mname}
        $stmt->bindValue(':{$fname}', ${$relname|lower}->{$mname});
{/foreach}
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) {ldelim}
            // instead do insert
            $sql = 'INSERT INTO {$rel.table} (';
{foreach $rel.myFields as $fname => $mnamel}
{if $mname@iteration == 1}
            $sql .= ' {$fname}';
{else}
            $sql .= ', {$fname}';
{/if}
{/foreach}
{foreach $rel.fields as $fname => $mname}
            $sql .= ', {$fname}';
{/foreach}
            $sql .= ') VALUES (';
{foreach $rel.myFields as $fname => $mname}
{if $mname@iteration == 1}
            $sql .= ' :{$fname}';
{else}
            $sql .= ', :{$fname}';
{/if}
{/foreach}
{foreach $rel.fields as $fname => $mname}
            $sql .= ', :{$fname}';
{/foreach}
            $sql .= ')';
            $stmt = $this->wdb->prepare($sql);
{foreach $rel.myFields as $fname => $mname}
            $stmt->bindParam(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
{foreach $rel.fields as $fname => $mname}
            $stmt->bindValue(':{$fname}', ${$relname|lower}->{$mname});
{/foreach}
            $stmt->execute();
            
            if ($stmt->rowCount() == 0) {ldelim}
                return false;
            {rdelim}
        {rdelim}
        
        return true;
    {rdelim}
    
    /**
     * unset {$relname} (as relationship)
     *
     * @access public
     * @return boolean
     */
    public function unset{$relname}() {ldelim}
        // do delete
        $sql = 'DELETE FROM {$rel.table}';
{foreach $rel.myFields as $fname => $mname}
        $sql .= ' {if $mname@iteration == 1}WHERE {else}AND {/if}{$fname} = :{$fname}';
{/foreach}
        $stmt = $this->wdb->prepare($sql);
{foreach $rel.myFields as $fname => $mnamel}
        $stmt->bindValue(':{$fname}', $this->properties['{$mname}']['value']);
{/foreach}
        $stmt->execute();
        
        if ($stmt->rowCount() == 0) {ldelim}
            return false;
        {rdelim}
        
        return true;
    {rdelim}
{/if}
{/foreach}
