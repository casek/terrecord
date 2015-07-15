    /**
     * properties
     * 
     * provides virtual properties below
{foreach $params as $param}
     *  - {$param.mname}	{$param.type}	{$param.desc}
{/foreach}
     * 
     * @var array
     * @access protected
     */
    protected $properties = array(
{foreach from=$params item=param}
        '{$param.mname}'=>array(
            'field_name'=>'{$param.name}',
            'type'=>'{$param.type}',
            'subtype'=>{$param.subtype},
            'defaultvalue'=>{$param.default},
            'value'=>{$param.default}
        ),
{/foreach}
    );

