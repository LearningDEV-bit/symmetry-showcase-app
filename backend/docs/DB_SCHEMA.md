Collection: articles (public news)

Document: /articles/{articleId}

Field	        Type	   Required	Notes
title	        string	   yes	        3–120 chars
description	string	   yes	        0–300 chars
content	        string	   yes	        full text
imageUrl	string	   no	        URL https
sourceName	string	   yes	        ej: “BBC”
sourceUrl	string	   yes	        URL https
publishedAt	timestamp  yes	        publication date
createdAt	timestamp  yes	        upload date
updatedAt	timestamp  no	        update date


Collection: posts (HBB / user-generated)

Documento: /posts/{postId}

Field	     Type	Required	Notes
authorId     string	yes	        request.auth.uid
title	     string	yes	        3–120 chars
body	     string	yes	        content
thumbnailUrl string	no	        URL https
createdAt    timestamp	yes	        server timestamp recommended
updatedAt    timestamp	no	        server timestamp
kind	     string	yes	        "hbb" (o flag isHbb: true)

Collection: users (profile)

Documento: /users/{uid}

Field	    Type	Required	Notes
displayName string	yes	        2–40 chars
photoUrl    string	no	        URL https
bio	    string	no	        0–160 chars
createdAt   timestamp	yes	        server timestamp

Note: In this implementation, editorial content (“Articles”) is stored in the posts collection for simplicity
and to reuse the same creation/editing workflow. Semantically, they are articles: they include title, content, timestamps
(createdAt, updatedAt), and a thumbnail in Storage under media/articles/<id>.jpg referenced by thumbnailPath.