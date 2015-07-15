{foreach $parents as $parent => $fields}
    /**
     * get {$parent} object (as parent)
     * 
     * @access public
     * @return {$parent}
     */
    public function get{$parent}() {ldelim}
        $loader =& {$parent}Loader::getInstance();
        return $loader->load(array({foreach $fields as $fname => $mname}{if $mname@iteration gt 1}, {/if}$this->properties['{$fname}']['value']{/foreach}));
    {rdelim}

{/foreach}
