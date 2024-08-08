const axios = require('axios');

const request1 = axios.get('http://localhost:4001/history');
const request2 = axios.get('http://localhost:4002/review-progress');

Promise.all([request1, request2])
  .then(responses => {
    const response1 = responses[0];
    const response2 = responses[1];
    console.log('Response from History API:', response1.data);
    console.log('Response from Review Progress API:', response2.data);
  })
  .catch(errors => {
    console.error(errors);
  });
