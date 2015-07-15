    /**
     * setter
     *
     * @access public
     * @ignore
     * @throws BadMethodCallException
     */
    public function __set($name, $value) {ldelim}
        if (!array_key_exists($name, $this->properties)) {ldelim}
            throw new BadMethodCallException(sprintf(_("Member '%s' is not found."), $name));
        {rdelim}
        
        // for type safe
        switch ($this->properties[$name]['type']) {ldelim}
            case 'integer':
                $value = (int)$value;
                break;
            case 'float':
                $value = (float)$value;
                break;
            case 'double':
                $value = (double)$value;
                break;
            case 'boolean':
                $value = (boolean)$value;
                break;
            case 'binary':
                $value = (string)$value;
                break;
            default:
                break;
        {rdelim}
        
        // error check here
        switch ($name) {ldelim}
            // FYI useful exceptions エラーの内容に適した例外を投げよう！
            //   Exception
            //     ErrorException
            //     LogicException       基本的にコードの修正が必要な例外
            //       BadFunctionCallException   関数の使い方がおかしい
            //       BadMethodCallException     使い方がおかしい
            //       DomainException            ENUMやフラグのパターン外
            //       InvalidArgumentException   渡される型がおかしい
            //       LengthException            文字列やバイナリの長い短い
            //       OutOfRangeException        数値の範囲外
            //     RuntimeException     実際の実行時に投げられる例外
            //       OutOfBoundsException	オブジェクトの状態によって範囲外
            //       RangeException             （オブジェクトの状態に関係なく）範囲外
            //       UnderflowException         アンダーフロー時
            //       UnexpectedValueException   予期しない値
{foreach $params as $param}
            case '{$param.mname}':
{if $param.regexp}
                // regexp check
{if substr($param.regexp, 0, 1) == '/' && substr($param.regexp, -1, 1) == '/'}
                if (!preg_match("{$param.regexp}", $value)) {ldelim}
{else}
                if (!mb_ereg("{$param.regexp}", $value)) {ldelim}
{/if}
                    throw new UnexpectedValueException(sprintf(_("Bad data format for member '%s'."), $name));
                {rdelim}
{/if}
{if $param.setter == false}
                throw new BadMethodCallException(sprintf(_("Write access denied for member '%s'."), $name));
{/if}
                break;
{/foreach}
        {rdelim}
        
        return parent::__set($name, $value);
    {rdelim}
    
