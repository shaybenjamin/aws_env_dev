add-content -path C:/Users/Benjamin/.ssh/config -value @'

Host ${hostname}
User ${user}
IdentityFile ${identityfile}
'@