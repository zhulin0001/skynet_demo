pb = require "protobuf"

pb.register_file "addressbook.pb"

stringbuffer = pb.encode("tutorial.Person", 
  {
    name = "Alice",
    id = 12345,
    phone = {
      {
        number = "87654321"
      },
    }
  })

result = pb.decode("tutorial.Person", stringbuffer)

print(result)
