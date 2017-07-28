cd proto

rm -rf *.pb

protoc --descriptor_set_out lobby_c2s.pb lobby_c2s.proto
protoc --descriptor_set_out lobby_s2c.pb lobby_s2c.proto
protoc --descriptor_set_out game_c2s.pb game_c2s.proto
protoc --descriptor_set_out game_s2c.pb game_s2c.proto
