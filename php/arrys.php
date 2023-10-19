<?php
//array of numbers 
$ages=[1,2,3,4,5,6];
print_r($ages);
//array of strings
$names=["apple","orange"];
print_r($names);


//assosiation array
$users=[
   ["name"=>"peter","age"=>20,"height"=>50],
   ["name"=>"peter","age"=>20,"height"=>50],
   ["name"=>"peter","age"=>20,"height"=>50],
   ["name"=>"peter","age"=>20,"height"=>50],
   ["name"=>"peter","age"=>20,"height"=>50]

];

 print(json_encode($users));


?>