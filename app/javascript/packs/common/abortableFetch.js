/*
  Adds function .abort() to fetch

  Assumes request is for a 
*/
const handleError = (err) => {
  // This surpresses abort error i.e. we terminated the request via abort()
  if !(err.code === DOMException.ABORT_ERR) {
    console.error(err);
  }
};

export default function abortableFetch(url, options = {}) {
  let controller = new AbortController();

  Object.assign(options, { "signal": controller.signal });
  
  let request = fetch(url, options).catch(handleError);
  request.abort = () => controller.abort();
  
  return request;
}
