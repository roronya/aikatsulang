build:
	goyacc parser.go.y
	go build

run:
	go run ./y.go
