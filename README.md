# Box-Mount
A shell script that automatically configures Rclone and mounts Box as a local filesystem.

I developed this during my internship with the Research Technologies group at Indiana University.
Our problem was simple, the only way to interact with university Box accounts was through WebDAV, an unreliable and slow interface.

After finding Rclone, I needed a way to make it more user-friendly. To remove most user interaction, I wrote a script that
uses OAuth to authorize the App on the Box API and then create a configuration file with the generated tokens.
