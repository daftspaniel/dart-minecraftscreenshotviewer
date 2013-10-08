import 'dart:io';
/***
 * Simple HTTP Server for displaying Minecraft screenshots on a web page.
 * v0.1
 */

List<String> imageFiles;
Map<String,String> webFiles;

// Update this path to reflect you system.
const String thePNGPath = "/home/user/.minecraft/screenshots";

void main() {
  
  webFiles = new Map();
  imageFiles = new List();
  print("Starting Server...");
  
  var dir = new Directory(thePNGPath);
  
  var contentsStream = dir.list(recursive:true);
  contentsStream.listen(
    (FileSystemEntity f) {
      if (f is File) {
        imageFiles.add(f.path);
        webFiles[f.path.substring(f.path.lastIndexOf('/')+1)] = f.path;
      } 
    },
    onError: (e) { print(e.toString()); }
  );
  
  HttpServer.bind('127.0.0.1', 8080).then((server) {
    server.listen((HttpRequest request) {
      
      // Serve Image
      if (request.uri.path.indexOf(".png")>-1)
      {
        File image = new File(webFiles[request.uri.toString().substring(1)]);
        image.readAsBytes().then(
            (raw){
              request.response.headers.set('Content-Type', 'image/png');
              request.response.headers.set('Content-Length', raw.length);
              request.response.add(raw);
              request.response.close();
              }
            );
      }
      else{
        
        // Serve Webpage
        request.response.write('<html>');
        request.response.write('<head><title>My Minecraft Screenshots</title></head');
        request.response.write('<body>');
        request.response.write('<h1>My Minecraft Screenshots</h1>');
        
        for (var img in webFiles.keys)
        {
          request.response.write('<a href="$img"><img src="$img" width="320" height="200" /></a>&nbsp;\r\n');
        }
        
        request.response.write('<body>');
        request.response.write('</html>');
        request.response.close();
      }
    });
  });
  
}
