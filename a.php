<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING^E_DEPRECATED );
function httpcurl($url,$post_data){
$ch = curl_init();  
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, 1);  
curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data); 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$r=curl_exec($ch);
curl_close($ch);   
return $r;
}

switch ($_GET['action']) {
	case 'air':
		$r=httpcurl("http://192.168.1.10?action=read");
		$r=str_replace("{","{\"",$r);
		$r=str_replace("}","\"}",$r);
		$r=str_replace(":","\":\"",$r);
		$r=str_replace(",","\",\"",$r);
		echo($r);
		break;
	case 'write':
		$r=httpcurl("http://192.168.1.10?action=write&pin=".$_GET['pin']."&level=".$_GET['level']);
		echo($r);
		break;
	case 'weather':
		$r=httpcurl("http://api.liebao.cn/newtab/index.php?r=weathernew/getXiaomiData&city_id=101020100");
		$r=json_decode(trim($r,"getXiaomiData()"));
		$w->aqi=$r->weatherInfo->aqi->aqi;
		$w->weather1=$r->yb->weatherinfo->weather1;
		$w->weather2=$r->yb->weatherinfo->weather2;
		$w->weather3=$r->yb->weatherinfo->weather3;
		$r=httpcurl("http://weather.123.duba.net/weatherinfo/?callback=getDuBaData");
		$r=json_decode(trim($r,"getDuBaData()"));
		$w->temp1=$r->weatherinfo->temp1;
		$w->temp2=$r->weatherinfo->temp2;
		$w->temp3=$r->weatherinfo->temp3;
		$r=httpcurl("http://www.duba.com/winfo/101020100.json");
		$r=json_decode($r);
		$w->n=$r->main->n;
		$w->tip=$r->pminfo->tip;
		echo(json_encode($w));
		break;
	case 'value':
		# code...
		break;
	case 'value':
		# code...
		break;
	
	default:
		# code...
		break;
}

?>