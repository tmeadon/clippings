import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
    discardResponseBodies: true,
    scenarios: {
      allocateVm: {
        executor: 'per-vu-iterations',
        vus: 2,
        iterations: 1,
      },
    },
  };

export default function () {

  let httpParams = {
    headers: {'Content-Type': 'application/json'},
    responseType: 'text'
  };

  var startUrl = `http://192.168.0.174:7071/api/orchestrators/orch`;

  var startRequest = http.get(startUrl, httpParams);

  check (startRequest, {
    'start status is 202': (req) => req.status === 202
  });

  var statusUpdateUrl = startRequest.json().statusQueryGetUri.replace('localhost','192.168.0.174');

  do {
    sleep(1);
    var statusUpdateRequest = http.get(statusUpdateUrl, httpParams);
    console.log(statusUpdateRequest.json().runtimeStatus);
  } while (statusUpdateRequest.json().runtimeStatus != 'Completed');

  console.log(statusUpdateRequest.json().output);

  let checkRegex = /^.*$/

  check (statusUpdateRequest, {
    'got an output value': (req) => checkRegex.test(req.json().output)
  })

  // var statusUpdateUrl = `http://192.168.0.174:7071/runtime/webhooks/durabletask/instances/400425a6-e4e3-47e1-becd-892156e442a9?taskHub=DurableFunctionsHub&connection=Storage&code=rmGCA1wsDxD/aleqpvQbgbZRtEoCviXXi2R/FZiCldwhFN/FrAsblw==`;
  
  // var status = http.get(statusUpdateUrl, params);
  
  // console.log(status.status);
  // console.log(status.json().name);
  
  // check(loadtest, {
  //   'status is 200': (loadtest) => loadtest.status === 200,
  // });
}



