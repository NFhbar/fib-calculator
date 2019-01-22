# Fibonacci Calculator

Over complicated Fibonacci calculator to illustrate multi-container application.

Stack:

- [nginx](https://www.nginx.com/)
- [redis](https://redis.io/)
- [react](https://reactjs.org/)
- [express](https://expressjs.com/)
- [postgres](https://www.postgresql.org/)
- [docker](https://www.docker.com/)
- [AWS Elastic beanstalk](https://aws.amazon.com/elasticbeanstalk/)

Each service is `dockerized` with development containers for testing and production
containers for deployment.

![Alt text](docs/fib-calculator.png?raw=true "architecture")

Nginx is used to route traffic to proper back end server:

![Alt text](docs/fib-calculator-2.png?raw=true "routing")

## Local Usage
In root folder:
```
$ docker-compose up --build
```

If first time running fails, might have to start twice.

Then visit `localhost:3050`. Input values and refresh page.
