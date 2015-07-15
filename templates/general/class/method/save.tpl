    /**
     * save
     *
     * @access public
     * @return boolean
     * @throws PDOException
     */
    public function save() {ldelim}
        if(!$this->changed) {ldelim}
            return false;
        {rdelim}
        $time = $this->getCurrentTimestamp();
        
        if ($this->loaded) {ldelim}
            // DO UPDATE
            $sql = 'UPDATE {$table} SET';
{assign "counter" 0}
{foreach $params as $key => $param}
{if $param.name != 'created' || $param.dbtype != 'timestamp'}
{if $param.primary != true}
            $sql .= '{if $counter!=0},{/if} {$param.name} = :{$param.name}';
{assign "counter" 1}
{/if}
{/if}
{/foreach}
{foreach $pkFields as $fname => $mname}
{if $mname@iteration == 1}
            $sql .= ' WHERE {$fname} = :{$fname}';
{else}
            $sql .= ' AND {$fname} = :{$fname}';
{/if}
{/foreach}
            $stmt = $this->db->prepare($sql);
{foreach $params as $k => $param}
{if $param.dbtype == 'timestamp'}
{if $param.name == 'created'}
{* ignore 'created' field for update *}
{elseif $param.name == 'modified'}
            $stmt->bindValue(':{$param.name}', date({if $db_type=='psql'}DATE_ISO8601{else}"Y-m-d H:i:s"{/if}, $time));
{else}
            $stmt->bindValue(':{$param.name}', date({if $db_type=='psql'}DATE_ISO8601{else}"Y-m-d H:i:s"{/if}, $this->properties['{$param.mname}']['value']));
{/if}
{else}
            $stmt->bindParam(':{$param.name}', $this->properties['{$param.mname}']['value']);
{/if}
{/foreach}
            $stmt->execute();
            
            if ($stmt->rowCount() == 1) {ldelim}
{if $hasModified}
                $this->properties['modified']['value'] = $time;
{/if}
                $this->changed = false;
                return true;
            {rdelim} else {ldelim}
                return false;
            {rdelim}
        {rdelim} else {ldelim}
{assign var='param' value=$params.0}
{if $db_type=='psql' && $param.sequence}
            // CHECK SEQUENCE '{$param.sequence}'
            $sql = 'SELECT NEXTVAL(:sequence)';
            $stmt = $this->db->prepare($sql);
            $stmt->bindValue(':sequence', '{$param.sequence}');
            $stmt->execute();
            
            $nextval = $stmt->fetchColumn();
            $this->properties['{$param.mname}']['value'] = $nextval;

{/if}
            // DO INSERT
            $sql = 'INSERT INTO {$table} (';
{assign "counter" 0}
{foreach $params as $param}
{if $db_type == 'psql' || $param.name != 'object_id'}
            $sql .= '{if $counter!=0},{/if} {$param.name}';
{assign "counter" 1}
{/if}
{/foreach}
            $sql .= ') VALUES (';
{assign "counter" 0}
{foreach $params as $param}
{if $db_type == 'psql' || $param.name != 'object_id'}
            $sql .= '{if $counter!=0},{/if} :{$param.name}';
{assign "counter" 1}
{/if}
{/foreach}
            $sql .= ')';
            $stmt = $this->db->prepare($sql);
{foreach $params as $k => $param}
{if $db_type == 'psql' || $param.name != 'object_id'}
{if $param.dbtype == 'timestamp'}
{if $param.name == 'created' || $param.name == 'modified'}
            $stmt->bindValue(':{$param.name}', date({if $db_type=='psql'}DATE_ISO8601{else}"Y-m-d H:i:s"{/if}, $time));
{else}
            $stmt->bindValue(':{$param.name}', date({if $db_type=='psql'}DATE_ISO8601{else}"Y-m-d H:i:s"{/if}, $this->properties['{$param.mname}']['value']));
{/if}
{else}
            $stmt->bindParam(':{$param.name}', $this->properties['{$param.mname}']['value']);
{/if}
{/if}
{/foreach}
            $stmt->execute();
            
            if ($stmt->rowCount() == 1) {ldelim}
{if $hasCreated}
                $this->properties['created']['value'] = $time;
{/if}
{if $hasModified}
                $this->properties['modified']['value'] = $time;
{/if}
                $this->loaded = true;
                $this->changed = false;
                return true;
            {rdelim} else {ldelim}
                return false;
            {rdelim}
        {rdelim}
    {rdelim}
    
