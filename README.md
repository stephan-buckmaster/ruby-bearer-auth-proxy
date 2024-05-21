Bearer Token Authentication (Reverse) Proxy

This Ruby application provides a simple bearer token authentication
layer for an unprotected upstream server.

### Introduction

Bearer token authorization is described in RFC 6750, e.g. https://datatracker.ietf.org/doc/html/rfc6750

In essence, bearer token authorization is a straightforward concept,
yet when looking for configuration instructions for Apache or nginx,
clear guidance is hard to find.

For example, a client can access a protected endpoint (/api/orders)
on api.example.com, by including their bearer token (here,
abc-super-secret-oh-no-now-its-not) in the Authorization header:


```
HTTP
GET /api/orders HTTP/1.1
Host: api.example.com
Authorization: Bearer abc-super-secret-oh-no-now-its-not
```

The client would have obtained this token (abc...now-its-not) through
a prior process, for example, by having a regular user logging into
a web application (such as github), accessing their api-tokens page,
and generating a new token. The regular user would communicate this token
to the team so that it becomes part of the API client configuration.

Whereas using the Authorization header with the format Authorization:
Bearer <token> is the standardized and recommended approach, there are
other ways (sections 2.2 and 2.3 in the RFC), but here we only consider that usage.

So here is a reverse proxy server, written in Ruby.

### Usage

Suppose you have an unprotected server running at http://localhost:12345,
and you want to make it available on the wider network at port 23456.

0. Install required ruby gems

```
bundle
```

1. Add some authentication tokens

Run 

```
ruby ./add_token_hash.rb >> bearer_token_hashes
```

Enter a few tokens, line by line.

2. Start the app

```
UPSTREAM_URL=http://localhost:12345 TOKEN_HASH_FILE=./bearer_token_hashes rackup app.rb -o 0.0.0.0 -p 23456
```

3. Now you can access the upstream server, but only when providing a valid token as entered in Step 1.
If your server is accessible by address 192.168.1.2, this should do the trick:

```
curl -H 'Authentication: Bearer one-of-your-tokens-from-step-1' http://192.168.1.2:23456
```

You can verify that the response will be an HTTP 401 error with message,
Invalid bearer token, when an invalid token is used:


```
curl -H 'Authentication: Bearer not-one-of-your-tokens-from-step-1' http://192.168.1.2:23456
```

Exercise: What happens when there is no Authentication header? Or when it doesn't have a Bearer?


### Tests
Tests can be executed with the usual ```rake``` command, or individually as in 
```
ruby test/app_test.rb
```
