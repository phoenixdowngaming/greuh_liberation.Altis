_p = _this select 1;
_i = _this select 2;
if (soundVolume == 0.1) then {
	0.1 fadeSound 1;
	_p setUserActionText [_i,"<t color='#ffff33'>Put on ear plugs</t>"];
} else {
	0.1 fadeSound 0.1;
	_p setUserActionText [_i,"<t color='#ffff33'>Take off ear plugs</t>"];
};