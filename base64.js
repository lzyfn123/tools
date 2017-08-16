Base64 = {
    encode64: function (str) {
      return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
        function toSolidBytes(match, p1) {
        return String.fromCharCode('0x' + p1);
      }))
    }, decode64: function () {
      return decodeURIComponent(atob(str).split('').map(function (c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
      }).join(''));
    }
 }
  
header = {typ: 'JWT', alg: 'HS256'}
// "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"
headerStr = Base64.encode64(JSON.stringify(header))
  
