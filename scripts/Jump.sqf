//if (isNull player) exitwith {} ;

fn_Animation =
{
    
	private ["_unit","_anim"];
	_unit = _this select 0;
	_anim = _this select 1;
	//_unit playMovenow "";
	_unit switchMove _anim;// PLAY ANIMATION JUMP
};

dokeyDown= {
	
	private ["_r","_key_delay","_max_height","_height","_vel","_dir","_speed","_key","_dikcode_getover_arr"];
	_dikcode_getover_arr = actionKeys "GetOver";
	_key = _this select 1;
	_key_delay  = 0.3;// MAX TIME BETWEEN KEY PRESSES 
	_max_height = 4.3;// SET MAX JUMP HEIGHT
	player setVariable ["key",false];// ENABLE THIS LINE FOR SINGLE KEYPRESS BY REMOVING // AT THE START OF THE LINE
	_r = false;
	//HINT STR (_this select 1);// show key number
   // VARIOUS CHECKS 
	if ((player getVariable ["key",true]) && (_key in _dikcode_getover_arr)) exitWith {player setVariable ["key",false]; [_key_delay] spawn {sleep (_this select 0);player setVariable ["key",true];};_r};
	if ((_key in _dikcode_getover_arr) && (speed player >8)) then {
		if ((player == vehicle player)  && (player getVariable ["jump",true]) && (isTouchingGround player )) then  {
			player setVariable ["key",true];// RESTE DOUBLE KEY TAP    
			player setVariable ["jump",false];// DISABLE JUMP
			_height = 6-((load player)*1);// REDUCE HEIGHT BASED ON WEIGHT
			//hint str _height;
			// MAKE JUMP IN RIGHT DIRECTION
			_vel = velocity player;
			_dir = direction player;
			_speed = 0.4;
			If (_height > _max_height) then {_height = _max_height};// MAXIMUM HEIGHT OF JUMP 
			player setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),(_vel select 2)+_height];
			[[player,"AovrPercMrunSrasWrflDf"],"fn_Animation",nil,false] spawn BIS_fnc_MP; //BROADCAST ANIMATION
			player spawn {sleep 2;_this setVariable ["jump",true]};// RE-ENABLE JUMP
		};
		_r = true;
	};
	_r;
};

waitUntil {!(IsNull (findDisplay 46))};
(FindDisplay 46) displayAddEventHandler ["keydown","_this call dokeyDown"];  