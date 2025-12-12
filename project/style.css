// script.js
// Dependencies required in index.html:
// <script src="https://cdn.jsdelivr.net/npm/papaparse@5.4.1/papaparse.min.js"></script>
// <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

// Utility functions
function toNum(v){ if(v==null||v==='') return null; return Number(String(v).replace(/[, $]/g,'')); }
function parseDate(s){
  const d = new Date(s);
  return isNaN(d) ? null : d;
}

// Dataset and chart contexts
let dataset = [];
const priceCtx = document.getElementById('priceChart').getContext('2d');
const volCtx = document.getElementById('volumeChart').getContext('2d');
let priceChart, volChart;

// File input + load button wiring
document.getElementById('loadBtn').addEventListener('click', ()=>{
  const f = document.getElementById('fileInput').files[0];
  if(!f){ alert('Choose a CSV file or ensure tesla.csv is in the folder and refresh.'); return; }
  const reader = new FileReader();
  reader.onload = e=>{ processCSV(e.target.result); runAllAnalyses(); }
  reader.readAsText(f);
});

// Auto-load tesla.csv when served over HTTP
window.addEventListener('load', ()=>{
  fetch('tesla.csv')
    .then(r=>{ if(!r.ok) throw new Error('no file'); return r.text(); })
    .then(t=>{ processCSV(t); runAllAnalyses(); })
    .catch(()=>{/* no remote auto-load */});
});

// CSV processing
function processCSV(text){
  const res = Papa.parse(text.trim(), {header:true, skipEmptyLines:true});
  const rows = res.data.map(r=>{
    const dt = parseDate(r.Date || r.date || r['Date Joined'] || r['date']);
    return {
      date: dt,
      dateStr: dt? dt.toISOString().slice(0,10) : null,
      open: toNum(r.Open),
      high: toNum(r.High),
      low: toNum(r.Low),
      close: toNum(r.Close) || toNum(r['Adj Close']) || toNum(r['Adj. Close']),
      adj_close: toNum(r['Adj Close']) || toNum(r['Adj. Close']) || toNum(r.Close),
      volume: toNum(r.Volume)
    };
  }).filter(r=>r.date && r.close!=null).sort((a,b)=>a.date-b.date);
  dataset = rows;
  document.getElementById('dataRange').textContent = dataset.length? `Range: ${dataset[0].dateStr} → ${dataset[dataset.length-1].dateStr}` : 'Range: -';
}

// ---- ANALYTICAL FUNCTIONS (14 analyses) ----
function calcDailyReturns(){
  const res = [];
  for(let i=1;i<dataset.length;i++){
    const prev = dataset[i-1].close; const cur = dataset[i].close;
    const ret = (cur - prev)/prev;
    res.push({date:dataset[i].dateStr, daily_return:ret});
  }
  return res;
}

function movingAverage(period){
  const ma = new Array(dataset.length).fill(null);
  let sum=0, q=[];
  for(let i=0;i<dataset.length;i++){
    q.push(dataset[i].close); sum+=dataset[i].close;
    if(q.length>period){ sum-=q.shift(); }
    if(q.length===period) ma[i]=sum/period;
  }
  return ma;
}

function yearlyAvg(){
  const map = {};
  dataset.forEach(d=>{ const y=d.date.getFullYear(); map[y]=(map[y]||[]).concat(d.close); });
  return Object.keys(map).sort().map(y=>({year:y, avg: map[y].reduce((a,b)=>a+b,0)/map[y].length}));
}

function highestLowest(){
  let hi=-Infinity, lo=Infinity, hiDate='', loDate='';
  dataset.forEach(d=>{ if(d.close>hi){hi=d.close;hiDate=d.dateStr} if(d.close<lo){lo=d.close;loDate=d.dateStr} });
  const avg = dataset.reduce((a,b)=>a+b.close,0)/dataset.length;
  return {highest:{price:hi,date:hiDate}, lowest:{price:lo,date:loDate}, avg};
}

function highestVolumeDay(){
  let v=-Infinity, vd=''; dataset.forEach(d=>{ if(d.volume>v){v=d.volume;vd=d.dateStr} }); return {volume:v,date:vd};
}

function totalVolumePerYear(){
  const map={}; dataset.forEach(d=>{ const y=d.date.getFullYear(); map[y]=(map[y]||0)+ (d.volume||0); }); return map;
}

function daysUpDown(){
  let up=0, down=0; for(let i=1;i<dataset.length;i++){ if(dataset[i].close>dataset[i-1].close) up++; else if(dataset[i].close<dataset[i-1].close) down++; }
  return {up,down};
}

function biggestSingleDayGainLoss(){
  let best=-Infinity, bestDate='', worst=Infinity, worstDate='';
  for(let i=1;i<dataset.length;i++){ const ret=(dataset[i].close-dataset[i-1].close)/dataset[i-1].close; if(ret>best){best=ret;bestDate=dataset[i].dateStr} if(ret<worst){worst=ret;worstDate=dataset[i].dateStr} }
  return {bestPct:best,worstPct:worst,bestDate,worstDate};
}

function volatilityHighLow(){
  return dataset.map(d=>({date:d.dateStr, volatility: (d.high - d.low)})).sort((a,b)=>b.volatility-a.volatility).slice(0,5);
}

function gapDays(){
  const gaps=[]; for(let i=1;i<dataset.length;i++){ const gap = dataset[i].open - dataset[i-1].close; gaps.push({date:dataset[i].dateStr, gap}); } return gaps.sort((a,b)=>Math.abs(b.gap)-Math.abs(a.gap)).slice(0,8);
}

function cumulativeReturnSeries(){
  let cum=1; const arr=[{date:dataset[0].dateStr,cumReturn:1}];
  for(let i=1;i<dataset.length;i++){ const r=(dataset[i].close/dataset[i-1].close); cum*=r; arr.push({date:dataset[i].dateStr, cumReturn:cum}); }
  return arr;
}

function rollingOneYearVolatility(){
  const out=[]; const windowSize=252; for(let i=0;i<dataset.length;i++){ if(i<windowSize-1){ out.push(null); continue; } const slice=dataset.slice(i-windowSize+1,i+1).map(d=>d.close); const mean=slice.reduce((a,b)=>a+b,0)/slice.length; const sd=Math.sqrt(slice.reduce((s,v)=>s+(v-mean)*(v-mean),0)/ (slice.length-1)); out.push(sd); } return out;
}

function monthlyAverageClose(){
  const map={}; dataset.forEach(d=>{ const key = `${d.date.getFullYear()}-${String(d.date.getMonth()+1).padStart(2,'0')}`; map[key]=(map[key]||[]).concat(d.close); });
  return Object.keys(map).sort().map(k=>({month:k,avg:map[k].reduce((a,b)=>a+b,0)/map[k].length}));
}

function breakout90(){
  const outs=[]; for(let i=90;i<dataset.length;i++){ const prev90 = Math.max(...dataset.slice(i-90,i).map(d=>d.close)); if(dataset[i].close>prev90) outs.push({date:dataset[i].dateStr,close:dataset[i].close,prev90}); } return outs;
}

// ---- RENDERING ----
function renderCharts(ma7,ma30){
  const labels = dataset.map(d=>d.dateStr);
  const closeData = dataset.map(d=>d.close);
  const ma7data = ma7;
  const ma30data = ma30;
  const volData = dataset.map(d=>d.volume||0);

  if(priceChart) priceChart.destroy();
  priceChart = new Chart(priceCtx,{
    type:'line',data:{labels, datasets:[
      {label:'Close', data:closeData, borderColor:'#0f172a', tension:0.15, pointRadius:0, borderWidth:2, fill:false},
      ...(document.getElementById('showMA7').checked? [{label:'MA 7', data:ma7data, borderColor:'#1f7a1f', borderDash:[6,4], tension:0.1, pointRadius:0, borderWidth:1}] : []),
      ...(document.getElementById('showMA30').checked? [{label:'MA 30', data:ma30data, borderColor:'#1f4ed8', borderDash:[4,4], tension:0.1, pointRadius:0, borderWidth:1}] : [])
    ]},options:{scales:{x:{type:'category',display:true}, y:{beginAtZero:false}},plugins:{legend:{display:true}}}
  });

  if(volChart) volChart.destroy();
  volChart = new Chart(volCtx,{type:'bar',data:{labels, datasets:[{label:'Volume',data:volData, backgroundColor:'rgba(15,23,42,0.6)'}]},options:{scales:{x:{display:false}, y:{beginAtZero:true}}}});
}

function renderSummary(results){
  const list = document.getElementById('analysisList'); list.innerHTML='';
  const items = [
    `Daily returns: computed ${dataset.length-1} daily returns.`,
    `Highest closing price: ${results.highest.price.toFixed(2)} on ${results.highest.date}.`,
    `Lowest closing price: ${results.lowest.price.toFixed(2)} on ${results.lowest.date}.`,
    `Average closing price: ${results.avg.toFixed(2)}.`,
    `Monthly average closing: ${monthlyAverageClose().length} months (sample shown).`,
    `Highest volume traded: ${results.highVol.volume.toLocaleString()} on ${results.highVol.date}.`,
    `Total volume per year: ${JSON.stringify(results.totalVol)}`,
    `Yearly average close: ${JSON.stringify(yearlyAvg().map(x=>x.year+':'+x.avg.toFixed(2)).slice(-5))}`,
    `Days with price increase: ${results.days.up}`,
    `Days with price decrease: ${results.days.down}`,
    `7-day moving average: computed`,
    `30-day moving average: computed`,
    `Biggest single-day % gain: ${(results.biggest.bestPct*100).toFixed(2)}% on ${results.biggest.bestDate}`,
    `Biggest single-day % loss: ${(results.biggest.worstPct*100).toFixed(2)}% on ${results.biggest.worstDate}`
  ];
  items.forEach(it=>{ const li=document.createElement('li'); li.textContent=it; list.appendChild(li); });

  document.getElementById('highestClose').textContent = results.highest.price.toFixed(2);
  document.getElementById('lowestClose').textContent = results.lowest.price.toFixed(2);
  document.getElementById('avgClose').textContent = results.avg.toFixed(2);
}

// Orchestrator
function runAllAnalyses(){
  if(!dataset.length) return;
  const ma7 = movingAverage(7);
  const ma30 = movingAverage(30);
  const dailyR = calcDailyReturns();
  const highest = highestLowest();
  const highVol = highestVolumeDay();
  const totalVol = totalVolumePerYear();
  const days = daysUpDown();
  const biggest = biggestSingleDayGainLoss();
  const volHL = volatilityHighLow();
  const gaps = gapDays();
  const cum = cumulativeReturnSeries();
  const rollingVol = rollingOneYearVolatility();
  const breakouts = breakout90();

  const results = {highest: highest.highest || highest.highest, lowest: highest.lowest || highest.lowest, avg: highest.avg, highVol, totalVol, days, biggest, volHL, gaps, cum, rollingVol, breakouts};

  renderCharts(ma7, ma30);
  renderSummary(results);

  ['showMA7','showMA30','showVolume'].forEach(id=>{ document.getElementById(id).addEventListener('change', ()=> renderCharts(ma7,ma30)); });
}