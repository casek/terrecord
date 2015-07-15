#!/usr/bin/env php
<?php
/**
 * terrecord.php
 * 
 * requirement:
 *      PEAR::Log
 *
 * @author Keisuke Mutoh <kmutoh@lefthandle.com>
 * @version 1.0
 * @package terrecord
 * @copyright Team Left Handle (http://lefthandle.com)
 * @license http://www.opensource.org/licenses/mit-license.php MIT
 */ 

try {
    // command line option
    $shortopts = "c:h";
    $longopts = array(
        "config:",
        "help"
    );
    $options = getopt($shortopts, $longopts);
    if(isset($options['h']) || isset($option['help'])) {
        print_usage();
        exit;
    }

    // register autoloader
    spl_autoload_register(function ($class) {
        $dirs = array (
            'classes',
            'classes/model',
            'classes/framework',
        );

        foreach($dirs as $dir) {
            $file = realpath(__DIR__.'/'.$dir.'/'.strtolower($class).'.php');
            if(file_exists($file)) {
                require_once $file;
                return;
            }
        }
    });
    
    // create TerRecord Object
    $config_file = "config.ini";
    if(isset($options['c'])) {
        $config_file = $options['c'];
    }
    if(isset($options['config'])) {
        $config_file = $options['config'];
    }
    $terrecord =& TerRecord::getInstance($config_file);

    // create Scheme Object
    switch($terrecord->getConfig('db','type')) {
    case 'psql':
        $scheme =& Psql::getInstance();
        break;
    case 'mysql':
        $scheme =& Mysql::getInstance();
        break;
    default:
        throw new Exception(_("can't find database type on your configuration..."));
    }
    $data = $scheme->createSchemeData();

    // create Framework Object
    switch($terrecord->getConfig('framework','type')) {
    case 'fuelphp':
        $framework =& Fuelphp::getInstance($data);
        break;
    default:
        throw new Exception(_("can't find framework type on your configuration..."));
    }

    // finally!! create files of model class
    $framework->createBaseClasses();
    $framework->createClasses();

} catch(Exception $e) {
    echo $e->getMessage()."\n";
}

function print_usage() {
    echo "\nUsage: php terrecord.php [options]\n\n";
    echo "  -c [--config]: configuration file path and name (this is option. default value is ./config.ini)\n";
    echo "  -h [--help]  : display this help\n\n";
}
?>
