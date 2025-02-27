
<H1> Cable Modem Data, how to record and plot, simplified</H1>

2017-04-13 paul chevalier

<a href="https://rawgit.com/epc002/cablemodemdata/master/index.html"> <img src="./misc/example-graphs.png" alt= "Select this for a live dygraph using example files within this repository"> </a>
<b> Select the image above to present a live graph instance using example data files within this repository (give it a while to display, there're a lot of datapoints to render). Try out the rolling average entries(lower left of each graph, default=10), and use the range selector bars under each graph(far left and right) to zoom in and move around the timeline. (note that the page auto-refreshes every 5 minutes)</b>
_____
<p>
<b>The Goal:</b><br>
Persistently capture and record statistics from an Arris SB6183 cable modem, and display historical plots in dygraphs.<br>
<p>
<b>Method Overview:</b><br>
<ul>
<li>Periodically run the cableModemCapture-SB6183.sh shell script via cron.</li>
<li>The script uses the lynx text-based web browser to capture statistical data from the cable modem.</li>
<li>It parses the data to extract target numerical data.</li>
<li>Then appends the timestamped numerical data to running CSV data files.</li>
<li>Graphic plots (using <a href="http://dygraphs.com">Dygraphs</a>) of the accumulated data are produced in realtime.</li>
</ul>

<b>Requirements/Dependencies:</b><br>
<ul>
<li>An Arris SB6183 cable modem to capture data from</li>
<li>A linux instance, or equivalent </li>
<li>dygraph-combined.js </li>
<li>A local web server(optional) running on the linux instance</li>
</ul>

<b>Operational files:</b><br>
<ul>
<li>cableModemCapture-SB6183.sh  (typically run every 5 minutes via cron)</li>
<li>index.html</li>
<li>dygraph-combined.js</li>
<li>crontab entry</li>
</ul>

<b>Data files: three running csv data files are appended to every time the shell script is run:</b><p>
<ul>
<li>DownPowerLevels.csv </li>
<li>SNR-Levels.csv</li>
<li>UpPowerLevels.csv</li>
</ul>

The index.html  file references those csv files, and uses dygraphs to produce graphic plots.  

A recommended implementation is to run this off a Raspberry-pi with a small UPS, as it’s useful for portability, persistence, and low power consumption. (most any host system can use this method, it only uses a basic shell, lynx, sed, grep, cut, dygraphs, and a scheduler)
<p>
Example file structure on Raspberry-pi:

/var/www/html

├── dygraph-combined.js<br>
├── index.html<br>
├── SB6183<br>
│   ├── CableModemCapture-SB6183.sh<br>
│   ├── DownPowerLevels.csv<br>
│   ├── SNR-Levels.csv<br>
│   └── UpPowerLevels.csv<br>


example crontab -l :<br>
0,5,10,15,20,25,30,35,40,45,50,55 * * * *  /bin/bash /var/www/html/SB6183/CableModemCapture-SB6183.sh
<br>

While the parsing parameters in the capture script are specific to an Arris SB6183 cable modem, they can easily be modified for other modems or devices that can produce a repeatable pattern of data via a URI.  To do that, use lynx to dump a text file of the target device data.  Then open the text file in an appropriate editor (e.g. notepad++) to easily determine the line numbers and field positions of the target data, and then adjust the parsing parameters in the capture script.
<br>
<br>

A typical parse event in the script performs a piped sequence of operations against the lynx-captured dump file similar to this:
<br>
<ul>
<li> use sed to trim to a target range of line numbers:  <pre><i><b> sed -n '23,38 p' </i></b></pre> </li>
<li> use grep to trim to lines that contain a target text identifier: <pre><i><b> grep dBmV </i></b></pre> </li>
<li> use sed to shrink multiple whitespace in each line: <pre><i><b> sed 's/   */ /g' </i></b></pre> </li>
<li> use cut with a whitespace delimiter and extract the target field of numerical data: <pre><i><b> cut -d" " -f 10 </i></b></pre> </li>
<li> use sed to transpose the extracted data into a single csv line: <pre><i><b> sed -e :a -e '/$/N; s/\n/,/; ta'  </i></b></pre> </li>
<li> append the timestamped csv line to the target cumulative csv file </li>
</ul>

<br>
<br>
Note that running a web server is only needed if you intend to view the plots via a browser from any system on your lan(preferred). You instead could just view the plots on the hosting system by pointing firefox to the local index.html file. (note that the non-web server method doesn’t work with Chrome browser because it disallows cross origin requests)



