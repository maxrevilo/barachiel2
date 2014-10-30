exports.httpBackendMock = ->
    angular.module("httpBackendMock", ["barachiel", "ngMockE2E", 'ngCookies'])
    .run ($httpBackend, $cookies, utils, BASE_URL)->
        users = {}
        user_list = []
        sessions = {}

        $httpBackend.whenGET(BASE_URL + "/users/me").respond (method, url, raw_data) ->
            # if $cookies.sessionId and (user_id = sessions[$cookies.sessionId])
            if $cookies.sessionId
                # [200, angular.toJson(users[user_id]), {}]
                [200, angular.toJson({}), {}]
            else
                [401, 'Invalid session', {}]


        $httpBackend.whenPOST(BASE_URL + "/auth/signup/").respond (method, url, raw_data) ->
            data = utils.from_form_params(raw_data)

            return [400, {"name":["name not defined: " + data.name]}, {}] unless data.name
            return [400, {"email":["Invalid email: " + data.email]}, {}]  unless data.email is "valid@email.com"
            if not data.password or data.password.length < 4
                return [400, {"password":["invalid password: " + data.password]}, {}]
            
            session_id = Math.random().toString(36)
            # Fakingly setting the session id:
            $cookies.sessionId = session_id

            user = data
            user.id = Math.random().toString(36)
            users[user.id] = user
            user_list.push user
            sessions[session_id] = user
            [200, angular.toJson(data), {'Set-Cookie':'sessionid='+session_id+';'}]

        
        $httpBackend.whenPOST(BASE_URL + "/auth/login/").respond (method, url, raw_data) ->
            data = utils.from_form_params(raw_data)

            return [400, {"username":["Invalid email: " + data.email]}, {}] unless data.username is "valid@email.com"
            if not data.password or data.password.length < 4
                return [400, {"password":["invalid password: " + data.password]}, {}]
            
            session_id = Math.random().toString(36)
            # Fakingly setting the session id:
            $cookies.sessionId = session_id

            user = data
            user.id = Math.random().toString(36)
            users[user.id] = user
            user_list.push user
            sessions[session_id] = user.id
            [200, angular.toJson(data), {'Set-Cookie':'sessionid='+session_id+';'}]


        $httpBackend.whenGET(BASE_URL + "/auth/logout/").respond (method, url, raw_data) ->
            if $cookies.sessionId and (user_id = sessions[$cookies.sessionId])
                delete sessions[$cookies.sessionId]
                [200, 'Ok', {}]
            else
                [401, 'Invalid session', {}]

        $httpBackend.whenGET(RegExp("\/.*")).passThrough()
