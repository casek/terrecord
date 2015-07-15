<?php
/**
 * fuelphp.php
 *
 * this is the framework class for fuelphp
 *
 * @author Keisuke Mutoh <kmutoh@lefthandle.com>
 * @version 1.0
 * @package terrecord
 * @copyright Team Left Handle (http://lefthandle.com)
 * @license http://www.opensource.org/licenses/mit-license.php MIT
 */

 /**
  * class Fuelphp
  *
  * this is the framework class for fuelphp
  *
  * @package terrecord
  */

class Fuelphp extends Framework
{
    /**
     * get instance (singleton)
     *
     * @access public
     * @return Fuelphp
     */
    public static function getInstance($scheme=array()) {
        if(Fuelphp::$framework == null) {
            Fuelphp::$framework = new Fuelphp($scheme);
        }
        return Fuelphp::$framework;
    }

    /**
     * create base class files
     */
    public function createBaseClasses() {
        $config = array_merge($this->terrecord->getConfig('setting'),$this->terrecord->getConfig('db'));
        $config['ext'] = $this->config['file_ext'];
        $config['db_type'] = $this->config['db_type'];
        $config['see'] = array();
        $config['params'] = array();
        $outputpath = $this->config['output'];
        
        // Connection
        $config['name'] = 'connection';
        $config['desc'] = 'the database connection class';
        $config['generate_type'] = 'baseclass';
        $contents = $this->smarty->fetch('fuelphp/baseclass/connection.tpl',$config);

        $fh = fopen($outputpath.'connection.php','w');
        fwrite($fh,$contents);
        fclose($fh);

        // TerRecord
        $config['name'] = 'terrecord';
        $config['desc'] = '';
        $config['generate_type'] = 'baseclass';
        $contents = $this->smarty->fetch('fuelphp/baseclass/terrecord.tpl',$config);

        $fh = fopen($outputpath.'terrecord.php','w');
        fwrite($fh,$contents);
        fclose($fh);

        // TerLoader
        $config['name'] = 'terrecordloader';
        $config['desc'] = '';
        $config['generate_type'] = 'baseclass';
        $contents = $this->smarty->fetch('fuelphp/baseclass/terrecordloader.tpl',$config);

        $fh = fopen($outputpath.'terrecordloader.php','w');
        fwrite($fh,$contents);
        fclose($fh);

        // TerList
        $config['name'] = 'terlist';
        $config['desc'] = '';
        $config['generate_type'] = 'baseclass';
        $contents = $this->smarty->fetch('fuelphp/baseclass/terlist.tpl',$config);

        $fh = fopen($outputpath.'terlist.php','w');
        fwrite($fh,$contents);
        fclose($fh);

        // TerListLoader
        $config['name'] = 'terlistloader';
        $config['desc'] = '';
        $config['generate_type'] = 'baseclass';
        $contents = $this->smarty->fetch('fuelphp/baseclass/terlistloader.tpl',$config);

        $fh = fopen($outputpath.'terlistloader.php','w');
        fwrite($fh,$contents);
        fclose($fh);
    }

    /**
     * create class files
     */
    public function createClasses() {
        foreach($this->scheme as $scheme) {
            if($scheme['name'] && $scheme['type']!='MO') {
                $scheme['ext'] = $this->config['file_ext'];
                $scheme['db_type'] = $this->config['db_type'];
                
                /*** record class ***/
                $contents = '';
                $classcontents = '';
                $scheme['classname'] = $scheme['name'];
                $scheme['name'] = strtolower($scheme['classname']);
                $scheme['generate_type'] = 'record';
                $filename = $this->config['output'].$scheme['name'].$scheme['ext'];
                
                // doc block for file 
                $contents .= $this->smarty->fetch('general/docblock.tpl',$scheme);

                // name space section
                $contents .= $this->smarty->fetch('fuelphp/namespace.tpl',$scheme);

                // doc block for class
                $contents .= $this->smarty->fetch('general/class/docblock.tpl',$scheme);

                // class contents
                $classcontents .= $this->smarty->fetch('general/class/property.tpl',$scheme);
                $classcontents .= $this->smarty->fetch('fuelphp/class/magicmethod/setter.tpl',$scheme);
                $classcontents .= $this->smarty->fetch('general/class/magicmethod/constructor.tpl',$scheme);
                $classcontents .= $this->smarty->fetch('general/class/magicmethod/destructor.tpl',$scheme);
                $classcontents .= $this->smarty->fetch('general/class/method/save.tpl',$scheme);
                $classcontents .= $this->smarty->fetch('general/class/method/delete.tpl',$scheme);
                $classcontents .= $this->smarty->fetch('general/class/method/parent.tpl',$scheme);
                $data = array(
                    'target'  => $scheme,
                    'schemes' => $this->scheme
                );
                $classcontents .= $this->smarty->fetch('general/class/method/child.tpl',$data);
                if(isset($scheme['relationships'])) {
                    $classcontents .= $this->smarty->fetch('general/class/method/relation.tpl',$scheme);
                }
                $scheme['classcontents'] = $classcontents;

                // class
                $contents .= $this->smarty->fetch('general/class/record.tpl',$scheme);

                // create class file
                $fh = fopen($filename,'w');
                fwrite($fh,$contents);
                fclose($fh);

                /*** loader class ***/
                $contents = '';
                $scheme['classcontents'] = '';
                $scheme['basename'] = $scheme['classname'];
                $scheme['classname'] = $scheme['classname'].'Loader';
                $scheme['name'] = strtolower($scheme['classname']);
                $scheme['generate_type'] = 'loader';
                $filename = $this->config['output'].$scheme['name'].$scheme['ext'];
                
                // doc block for file 
                $contents .= $this->smarty->fetch('general/docblock.tpl',$scheme);

                // name space section
                $contents .= $this->smarty->fetch('fuelphp/namespace.tpl',$scheme);

                // doc block for class
                $contents .= $this->smarty->fetch('general/class/docblock.tpl',$scheme);

                // class contents
                $scheme['classcontents'] = $this->smarty->fetch('fuelphp/class/method/loader.tpl',$scheme);
                
                // class
                $contents .= $this->smarty->fetch('general/class/loader.tpl',$scheme);

                // create class file
                $fh = fopen($filename,'w');
                fwrite($fh,$contents);
                fclose($fh);
                
                /*** list class ***/
                $contents = '';
                $scheme['classcontents'] = '';
                $scheme['classname'] = $scheme['basename'].'List';
                $scheme['name'] = strtolower($scheme['classname']);
                $scheme['generate_type'] = 'list';
                $filename = $this->config['output'].$scheme['name'].$scheme['ext'];
                
                // doc block for file 
                $contents .= $this->smarty->fetch('general/docblock.tpl',$scheme);

                // name space section
                $contents .= $this->smarty->fetch('fuelphp/namespace.tpl',$scheme);

                // doc block for class
                $contents .= $this->smarty->fetch('general/class/docblock.tpl',$scheme);

                // class contents
                $scheme['classcontents'] = $this->smarty->fetch('fuelphp/class/method/list.tpl',$scheme);
                
                // class
                $contents .= $this->smarty->fetch('general/class/list.tpl',$scheme);

                // create class file
                $fh = fopen($filename,'w');
                fwrite($fh,$contents);
                fclose($fh);

                /*** listloader class ***/
                $contents = '';
                $scheme['classcontents'] = '';
                $scheme['basename'] .= 'List';
                $scheme['classname'] = $scheme['basename'].'Loader';
                $scheme['name'] = strtolower($scheme['classname']);
                $scheme['generate_type'] = 'listloader';
                $filename = $this->config['output'].$scheme['name'].$scheme['ext'];
                
                // doc block for file 
                $contents .= $this->smarty->fetch('general/docblock.tpl',$scheme);

                // name space section
                $contents .= $this->smarty->fetch('fuelphp/namespace.tpl',$scheme);

                // doc block for class
                $contents .= $this->smarty->fetch('general/class/docblock.tpl',$scheme);

                // class contents
                $scheme['classcontents'] = $this->smarty->fetch('fuelphp/class/method/listloader.tpl',$scheme);
                
                // class
                $contents .= $this->smarty->fetch('general/class/listloader.tpl',$scheme);

                // create class file
                $fh = fopen($filename,'w');
                fwrite($fh,$contents);
                fclose($fh);
            }
        }
    }
}
?>
