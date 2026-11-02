echo -e "#!/bin/sh\nid; ls -la" | tee /upload/script ; chmod +x /upload/script
/upload/script
