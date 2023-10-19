<?php

class Animal {
     public $name;
     public $color;
     public $legs;

    // public function __constuct( $name,$color,$legs){
    //     echo "called";
    //     $this->name=$name;
    //     $this->color=$color;
    //     $this->legs=$legs;
    
    // }
}

$obj1 = new Animal("cat","Red",4);
echo $obj1->color;
echo "hello";

?>