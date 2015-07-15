    /**
     * delete
     *
     * @access public
     * @return boolean
     * @throws PDOException
     */
    public function delete() {ldelim}
        if(!$this->loaded) {ldelim}
            return false;
        {rdelim}
        
        $sql = 'DELETE FROM {$table}';
{foreach $pkFields as $fname => $mname}
{if $mname@iteration == 1}
        $sql .= ' WHERE {$fname} = :{$fname}';
{else}
        $sql .= ' AND {$fname} = :{$fname}';
{/if}
{/foreach}
        $stmt = $this->db->prepare($sql);
{foreach $params as $param}
{if $param.primary == true}
        $stmt->bindValue(':{$param.name}', $this->properties['{$param.mname}']['value']);
{/if}
{/foreach}
        $stmt->execute();
        
        if ($stmt->rowCount() == 1) {ldelim}
            $this->setDefault();
        {rdelim} else {ldelim}
            return false;
        {rdelim}
        return true;
    {rdelim}
    
