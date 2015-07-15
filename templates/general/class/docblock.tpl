/**
 * class {if isset($classname)}{$classname}{else}{$name}{/if}

 *
{if $desc && ($generate_type == 'record' || $generate_type == 'baseclass')}
 * {$desc}
 *
{elseif $generate_type == 'loader' || $generate_type == 'listloader'}
 * loader for {$basename} (as {$basename} factory)
 *
{elseif $generate_type == 'list'}
 * list class for {$basename}
 *
{/if}
{if $package}
 * @package {$package}
{/if}
{if count($see)}
 {foreach $see as $key => $item}{if $key==0}* @see {else}, {/if}{if $namespace}{$namespace}\{/if}{$item}{/foreach}

{/if}
{if count($params) && $generate_type == 'record'}

{foreach $params as $param}
{if $param.setter == false}
 * @property-read {$param.type} ${$param.mname} {$param.desc}
{elseif $param.getter == false}
 * @property-write {$param.type} ${$param.mname} {$param.desc}
{else}
 * @property {$param.type} ${$param.mname} {$param.desc}
{/if}
{/foreach}
{/if}
 */
