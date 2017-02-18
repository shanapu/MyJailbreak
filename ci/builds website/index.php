<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
	
		<link rel="icon" href="favicon.ico">
	
		<title>MyJailbreaks builds</title>
	
		<!-- Bootstrap CSS -->
	
		<link href="../../dist/css/bootstrap.superhero.min.css" rel="stylesheet">
	
		<!-- Custom styles for this template -->
	
		<link href="theme.css" rel="stylesheet">
	
	</head>
	
	<!-- Messure page generation time -->
	
	<?php
	$time = microtime();
	$time = explode(' ', $time);
	$time = $time[1] + $time[0];
	$start = $time;
	?>
	
	<body>
		
		<!-- Fixed top navbar -->
		<nav class="navbar navbar-default navbar-fixed-top">
			<div class="container">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</button>
					
					<a class="navbar-brand" href="#"><B>MyJailbreak</B> builds</a>
					
				</div>
				
				<div id="navbar" class="navbar-collapse collapse">
					<ul class="nav navbar-nav">
						<li class="active">
							<a href="http://shanapu.de/MyJailbreak"><span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;downloads</a>
						</li>
						<li>
							<a href="http://github.com/shanapu/MyJailbreak" target="_blank"><span class="icon-github"></span>&nbsp;&nbsp;&nbsp;github</a>
						</li>
						<li>
							<a href="https://forums.alliedmods.net/showthread.php?t=283212" target="_blank"><span class="icon-allied"></span>&nbsp;&nbsp;&nbsp;alliedmodders</a>
						</li>
						<li>
							<a href="https://shanapu.de/MyJailShop" target="_blank"><span class="glyphicon glyphicon-paperclip" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;MyJailShop</a>
						</li>
					</ul>
				</div>
			</div>
		</nav>
		<!-- /Fixed navbar -->
		
		<br>
		
		<!-- tabsbar -->
		<ul class="nav nav-tabs" id="rowTab">
			<li>
				<a href="#sm17" data-toggle="tab"><span class="icon-price-tag"></span>&nbsp;&nbsp;compiled with Sourcemod <u><b>1.7</b></u></a>
			</li>
			<li class="active">
				<a href="#sm18" data-toggle="tab"><span class="icon-price-tag"></span>&nbsp;&nbsp;compiled with Sourcemod <u><b>1.8</b></u></a>
			</li>
			<li>
				<a href="#sm19" data-toggle="tab"><span class="icon-price-tag"></span>&nbsp;&nbsp;compiled with Sourcemod <u><b>1.9</b></u></a>
			</li>
		</ul>
		<!-- /tabsbar -->
		
		<br>
		<br>
		
		<!-- tabs content -->
		<div class="tab-content">
			<div class="tab-pane" id="sm17">
				<div class="row">
					<div class="col-md-6">
						<div class="panel panel-info">
							<div class="panel-heading">
								<h3 class="panel-title">
									<span class="icon-git-branch"></span>&nbsp;&nbsp;master
									<ul style="float:right; "><a href="https://travis-ci.org/shanapu/MyJailbreak?branch=master" target="_blank"><img src="https://img.shields.io/travis/shanapu/MyJailbreak/master.svg?style=flat-square"></a>
									</ul>
								</h3>
							</div>
							<div class="panel-body">
								<table class="table table-striped">
									
									<p>
									
									<p>
									<a href="http://shanapu.de/MyJailbreak/downloads/SM1.7/MyJB-master-latest.zip"><button type="button" class="btn btn-success"><span class="glyphicon glyphicon-save" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;download latest</button></a>
									<a href="http://github.com/shanapu/MyJailbreak/" target="_blank"><button type="button" class="btn btn-default"><span class="icon-code"></span>&nbsp;&nbsp;&nbsp;sourcecode</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/commits/master" target="_blank"><button type="button" class="btn btn-default"><span class="icon-git-commit"></span>&nbsp;&nbsp;&nbsp;commits</button></a>
									</p>
									
									<br>
									
									<thead>
										<tr>
										<th>Build Time - UTC</th>
										<th>Commit</th>
										<th>File Name</th>
										<th>Download</th>
										<th>Size</th>
										</tr>
									</thead>
									<tbody>
										
										<?php
										function scan_dir($dir) {
											$ignored = array('.', '..', '.svn', '.htaccess');
											$files = array();	
											foreach (scandir($dir) as $file) {
												if (in_array($file, $ignored)) continue;
												$files[$file] = filemtime($dir . '/' . $file);
											}
											arsort($files);
											$files = array_keys($files);
											return ($files) ? $files : false;
										}
										?>
										<?php
										// Ordnername 
										$ordner = "downloads/SM1.7/master/"; //auch komplette Pfade möglich ($ordner = "download/files";)
										
										// Ordner auslesen und Array in Variable speichern
										$alledateien = scan_dir($ordner); // Sortierung A-Z
										// Sortierung Z-A mit scandir($ordner, 1)
										
										// Schleife um Array "$alledateien" aus scandir Funktion auszugeben
										// Einzeldateien werden dabei in der Variabel $datei abgelegt
										foreach ($alledateien as $datei) {
											
											// Zusammentragen der Dateiinfo
											$dateiinfo = pathinfo($ordner."/".$datei); 
											//Folgende Variablen stehen nach pathinfo zur Verfügung
											// $dateiinfo['filename'] =Dateiname ohne Dateiendung	*erst mit PHP 5.2
											// $dateiinfo['dirname'] = Verzeichnisname
											// $dateiinfo['extension'] = Dateityp -/endung
											// $dateiinfo['basename'] = voller Dateiname mit Dateiendung
											$commit = substr($dateiinfo['filename'], -7);
											
											$filetimestamp = filemtime ($ordner."/".$datei);
											$filetime = date("d/m/y - H:i:s", $filetimestamp);
											// Größe ermitteln zur Ausgabe
											$size = round(filesize($ordner."/".$datei)/1048576,2); 
											//1024 = kb | 1048576 = MB | 1073741824 = GB
											
											// scandir liest alle Dateien im Ordner aus, zusätzlich noch "." , ".." als Ordner
											// Nur echte Dateien anzeigen lassen und keine "Punkt" Ordner
											// _notes ist eine Ergänzung für Dreamweaver Nutzer, denn DW legt zur besseren Synchronisation diese Datei in den Orndern ab
											if ($datei != "." && $datei != ".."	&& $datei != "_notes") { 
										?>
										<tr>
										<td><?php echo $filetime; ?></td>
										<td><a href="https://github.com/shanapu/MyJailbreak/commit/<?php echo $commit ; ?>" target="_blank"><?php echo $commit ; ?></a></td>
										<td><?php echo $dateiinfo['filename']; ?></td> 
										<td><a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>"><span class="glyphicon glyphicon-save" aria-hidden="false"></span></a></td>
										<td><?php echo $size ; ?> MB</td>
										</tr>
										<?php
											};
										};
										?>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<div class="col-md-6">
						<div class="panel panel-warning">
							<div class="panel-heading">
								<h3 class="panel-title">
									<span class="icon-git-branch"></span>&nbsp;&nbsp;develop
									<ul style="float:right; "><a href="https://travis-ci.org/shanapu/MyJailbreak?branch=dev" target="_blank"><img src="https://img.shields.io/travis/shanapu/MyJailbreak/dev.svg?style=flat-square"></a>
									</ul>
								</h3>
							</div>
							<div class="panel-body">
								<table class="table table-striped">
									
									<p>
									
									<p>
									<a href="http://shanapu.de/MyJailbreak/downloads/SM1.7/MyJB-dev-latest.zip"><button type="button" class="btn btn-success"><span class="glyphicon glyphicon-save" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;download latest</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/tree/dev" target="_blank"><button type="button" class="btn btn-default"><span class="icon-code"></span>&nbsp;&nbsp;&nbsp;sourcecode</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/commits/dev" target="_blank"><button type="button" class="btn btn-default"><span class="icon-git-commit"></span>&nbsp;&nbsp;&nbsp;commits</button></a>
									</p>
									
									<br>
									
									<thead>
										<tr>
										<th>Build Time - UTC</th>
										<th>Commit</th>
										<th>File Name</th>
										<th>Download</th>
										<th>Size</th>
										</tr>
									</thead>
									<tbody>
										<?php
										$ordner = "downloads/SM1.7/dev/";
										
										$alledateien = scan_dir($ordner);
										
										foreach ($alledateien as $datei) {
										
											$dateiinfo = pathinfo($ordner."/".$datei); 
											
											$commit = substr($dateiinfo['filename'], -7);
											
											$filetimestamp = filemtime ($ordner."/".$datei);
											$filetime = date("d/m/y - H:i:s", $filetimestamp);
											
											$size = round(filesize($ordner."/".$datei)/1048576,2); 
											
											if ($datei != "." && $datei != ".."	&& $datei != "_notes") { 
											?>
											<tr>
											<td><?php echo $filetime; ?></td>
											<td><a href="https://github.com/shanapu/MyJailbreak/commit/<?php echo $commit ; ?> target="_blank""><?php echo $commit ; ?></a></td>
											<td><?php echo $dateiinfo['filename']; ?></td> 
											<td><a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>"><span class="glyphicon glyphicon-save" aria-hidden="false"></span></a></td>
											<td><?php echo $size ; ?> MB</td>
											</tr>
										<?php
											};
										};
										?>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
			
			<div class="tab-pane active" id="sm18">
				<div class="row">
					<div class="col-md-6">
						<div class="panel panel-info">
							<div class="panel-heading">
								<h3 class="panel-title">
									<span class="icon-git-branch"></span>&nbsp;&nbsp;master
									<ul style="float:right; "><a href="https://travis-ci.org/shanapu/MyJailbreak?branch=master" target="_blank"><img src="https://img.shields.io/travis/shanapu/MyJailbreak/master.svg?style=flat-square"></a>
									</ul>
								</h3>
							</div>
							<div class="panel-body">
								<table class="table table-striped">
									
									<p>
									
									<p>
									<a href="http://shanapu.de/MyJailbreak/downloads/SM1.8/MyJB-master-latest.zip"><button type="button" class="btn btn-success"><span class="glyphicon glyphicon-save" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;download latest</button></a>
									<a href="http://github.com/shanapu/MyJailbreak/" target="_blank"><button type="button" class="btn btn-default"><span class="icon-code"></span>&nbsp;&nbsp;&nbsp;sourcecode</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/commits/master" target="_blank"><button type="button" class="btn btn-default"><span class="icon-git-commit"></span>&nbsp;&nbsp;&nbsp;commits</button></a>
									</p>
									
									<br>
									
									<thead>
										<tr>
										<th>Build Time - UTC</th>
										<th>Commit</th>
										<th>File Name</th>
										<th>Download</th>
										<th>Size</th>
										</tr>
									</thead>
									<tbody>
										<?php
										$ordner = "downloads/SM1.8/master/";
										
										$alledateien = scan_dir($ordner);
										
										foreach ($alledateien as $datei) {
										
											$dateiinfo = pathinfo($ordner."/".$datei);
											
											$commit = substr($dateiinfo['filename'], -7);
											
											$filetimestamp = filemtime ($ordner."/".$datei);
											$filetime = date("d/m/y - H:i:s", $filetimestamp);
											
											$size = round(filesize($ordner."/".$datei)/1048576,2); 
											
											if ($datei != "." && $datei != ".."	&& $datei != "_notes") { 
										?>
										<tr>
										<td><?php echo $filetime; ?></td>
										<td><a href="https://github.com/shanapu/MyJailbreak/commit/<?php echo $commit ; ?>" target="_blank"><?php echo $commit ; ?></a></td>
										<td><?php echo $dateiinfo['filename']; ?></td> 
										<td><a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>"><span class="glyphicon glyphicon-save" aria-hidden="false"></span></a></td>
										<td><?php echo $size ; ?> MB</td>
										</tr>
										<?php
											};
										};
										?>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<div class="col-md-6">
						<div class="panel panel-warning">
							<div class="panel-heading">
								<h3 class="panel-title">
									<span class="icon-git-branch"></span>&nbsp;&nbsp;develop
									<ul style="float:right; "><a href="https://travis-ci.org/shanapu/MyJailbreak?branch=dev" target="_blank"><img src="https://img.shields.io/travis/shanapu/MyJailbreak/dev.svg?style=flat-square"></a>
									</ul>
								</h3>
							</div>
							<div class="panel-body">
								<table class="table table-striped">
									
									<p>
									
									<p>
									<a href="http://shanapu.de/MyJailbreak/downloads/SM1.8/MyJB-dev-latest.zip"><button type="button" class="btn btn-success"><span class="glyphicon glyphicon-save" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;download latest</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/tree/dev" target="_blank"><button type="button" class="btn btn-default"><span class="icon-code"></span>&nbsp;&nbsp;&nbsp;sourcecode</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/commits/dev" target="_blank"><button type="button" class="btn btn-default"><span class="icon-git-commit"></span>&nbsp;&nbsp;&nbsp;commits</button></a>
									</p>
									
									<br>
									
									<thead>
										<tr>
										<th>Build Time - UTC</th>
										<th>Commit</th>
										<th>File Name</th>
										<th>Download</th>
										<th>Size</th>
										</tr>
									</thead>
									<tbody>
										<?php
										$ordner = "downloads/SM1.8/dev/";
										
										$alledateien = scan_dir($ordner);
										
										foreach ($alledateien as $datei) {
										
											$dateiinfo = pathinfo($ordner."/".$datei);
											
											$commit = substr($dateiinfo['filename'], -7);
											
											$filetimestamp = filemtime ($ordner."/".$datei);
											$filetime = date("d/m/y - H:i:s", $filetimestamp);
											
											$size = round(filesize($ordner."/".$datei)/1048576,2); 
											
											if ($datei != "." && $datei != ".."	&& $datei != "_notes") { 
										?>
										<tr>
										<td><?php echo $filetime; ?></td>
										<td><a href="https://github.com/shanapu/MyJailbreak/commit/<?php echo $commit ; ?>" target="_blank"><?php echo $commit ; ?></a></td>
										<td><?php echo $dateiinfo['filename']; ?></td> 
										<td><a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>"><span class="glyphicon glyphicon-save" aria-hidden="false"></span></a></td>
										<td><?php echo $size ; ?> MB</td>
										</tr>
										<?php
											};
										};
										?>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
			
			<div class="tab-pane" id="sm19">
				<div class="row">
					<div class="col-md-6">
						<div class="panel panel-info">
							<div class="panel-heading">
								<h3 class="panel-title">
									<span class="icon-git-branch"></span>&nbsp;&nbsp;master
									<ul style="float:right; "><a href="https://travis-ci.org/shanapu/MyJailbreak?branch=master" target="_blank"><img src="https://img.shields.io/travis/shanapu/MyJailbreak/master.svg?style=flat-square"></a>
									</ul>
								</h3>
							</div>
							<div class="panel-body">
								<table class="table table-striped">
								
									<p>
									
									<p>
									<a href="http://shanapu.de/MyJailbreak/downloads/SM1.9/MyJB-master-latest.zip"><button type="button" class="btn btn-success"><span class="glyphicon glyphicon-save" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;download latest</button></a>
									<a href="http://github.com/shanapu/MyJailbreak/" target="_blank"><button type="button" class="btn btn-default"><span class="icon-code"></span>&nbsp;&nbsp;&nbsp;sourcecode</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/commits/master" target="_blank"><button type="button" class="btn btn-default"><span class="icon-git-commit"></span>&nbsp;&nbsp;&nbsp;commits</button></a>
									</p>
									
									<br>
									
									<thead>
										<tr>
										<th>Build Time - UTC</th>
										<th>Commit</th>
										<th>File Name</th>
										<th>Download</th>
										<th>Size</th>
										</tr>
									</thead>
									<tbody>
										<?php
										$ordner = "downloads/SM1.9/master/";
										
										$alledateien = scan_dir($ordner);
										
										foreach ($alledateien as $datei) {
										
											$dateiinfo = pathinfo($ordner."/".$datei); 
											
											$commit = substr($dateiinfo['filename'], -7);
											
											$filetimestamp = filemtime ($ordner."/".$datei);
											$filetime = date("d/m/y - H:i:s", $filetimestamp);
											
											$size = round(filesize($ordner."/".$datei)/1048576,2); 
											
											if ($datei != "." && $datei != ".."	&& $datei != "_notes") { 
										?>
										<tr>
										<td><?php echo $filetime; ?></td>
										<td><a href="https://github.com/shanapu/MyJailbreak/commit/<?php echo $commit ; ?>" target="_blank"><?php echo $commit ; ?></a></td>
										<td><?php echo $dateiinfo['filename']; ?></td> 
										<td><a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>"><span class="glyphicon glyphicon-save" aria-hidden="false"></span></a></td>
										<td><?php echo $size ; ?> MB</td>
										</tr>
										<?php
											};
										};
										?>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<div class="col-md-6">
						<div class="panel panel-warning">
							<div class="panel-heading">
								<h3 class="panel-title">
									<span class="icon-git-branch"></span>&nbsp;&nbsp;develop
									<ul style="float:right; "><a href="https://travis-ci.org/shanapu/MyJailbreak?branch=dev" target="_blank"><img src="https://img.shields.io/travis/shanapu/MyJailbreak/dev.svg?style=flat-square"></a>
									</ul>
								</h3>
							</div>
							<div class="panel-body">
								<table class="table table-striped">
								
									<p>
									
									<p>
									<a href="http://shanapu.de/MyJailbreak/downloads/SM1.9/MyJB-dev-latest.zip"><button type="button" class="btn btn-success"><span class="glyphicon glyphicon-save" aria-hidden="true"></span>&nbsp;&nbsp;&nbsp;download latest</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/tree/dev" target="_blank"><button type="button" class="btn btn-default"><span class="icon-code"></span>&nbsp;&nbsp;&nbsp;sourcecode</button></a>
									<a href="https://github.com/shanapu/MyJailbreak/commits/dev" target="_blank"><button type="button" class="btn btn-default"><span class="icon-git-commit"></span>&nbsp;&nbsp;&nbsp;commits</button></a>
									</p>
									
									<br>
									
									<thead>
										<tr>
										<th>Build Time - UTC</th>
										<th>Commit</th>
										<th>File Name</th>
										<th>Download</th>
										<th>Size</th>
										</tr>
									</thead>
									<tbody>
										<?php
										
										$ordner = "downloads/SM1.9/dev/";
										 
										$alledateien = scan_dir($ordner);
										
										foreach ($alledateien as $datei) {
										
											$dateiinfo = pathinfo($ordner."/".$datei); 
											
											$commit = substr($dateiinfo['filename'], -7);
											
											$filetimestamp = filemtime ($ordner."/".$datei);
											$filetime = date("d/m/y - H:i:s", $filetimestamp);
											
											$size = round(filesize($ordner."/".$datei)/1048576,2); 
											
											if ($datei != "." && $datei != ".."	&& $datei != "_notes") { 
										?>
										<tr>
										<td><?php echo $filetime; ?></td>
										<td><a href="https://github.com/shanapu/MyJailbreak/commit/<?php echo $commit ; ?>" target="_blank"><?php echo $commit ; ?></a></td>
										<td><?php echo $dateiinfo['filename']; ?></td> 
										<td><a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>"><span class="glyphicon glyphicon-save" aria-hidden="false"></span></a></td>
										<td><?php echo $size ; ?> MB</td>
										</tr>
										<?php
											};
										};
										?>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
				<script>
				
					function getCookie(c_name) {
						var i, x, y, ARRcookies = document.cookie.split(";");
						for (i = 0; i < ARRcookies.length; i++) {
						x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
						y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
						x = x.replace(/^\s+|\s+$/g, "");
						if (x == c_name) {
							return unescape(y);
						}
						}
					}
					
					function setCookie(c_name, value, exdays) {
						console.log(c_name+"-->"+value);
						var exdate = new Date();
						exdate.setDate(exdate.getDate() + exdays);
						var c_value = escape(value) + ((exdays === null) ? "" : "; expires=" + exdate.toUTCString());
						document.cookie = c_name + "=" + c_value;
					}
					
					$("ul").click(function(){
						$("ul.nav-tabs").tabs("div.tab-content > div");
						 var api = $("ul.nav-tabs").data("tabs");
						 api.onClick(function(e, index) {
								setCookie("selectedtab", index + 1, 365);
						 });	 
						 var selectedTab = getCookie("selectedtab");
						 if (selectedTab != "undefined") {
						api.click( parseInt(selectedTab) ); 
						 }
					});
				</script>
			</div>
		</div>
		<!-- /tabs content -->
		<!-- /container -->
		
		<br>
		<br>
		
		<?php
		$time = microtime();
		$time = explode(' ', $time);
		$time = $time[1] + $time[0];
		$finish = $time;
		$total_time = round(($finish - $start), 4);
		?>
		
		<div class="well">
			<p>coded with <span class="glyphicon glyphicon-heart" aria-hidden="false"></span> by <a href="http://shanapu.de" target="_blank">shanapu.de</a>
			<p>Love goes out to alliedmodders, github, travis & bootstrap</p>
			<p><?php 
					echo 'Page generated in '.$total_time.' seconds.';
			?>
			</p>
		</div>
		
		<!-- Bootstrap core JavaScript
		================================================== -->
		<!-- Placed at the end of the document so the pages load faster -->
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
		<script>window.jQuery || document.write('<script src="../../assets/js/vendor/jquery.min.js"><\/script>')</script>
		<script src="../../dist/js/bootstrap.min.js"></script>
		<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
		<script src="../../assets/js/ie10-viewport-bug-workaround.js"></script>
	</body>
</html>