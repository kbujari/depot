{-# LANGUAGE OverloadedStrings #-}

{-|
Site layout:

Index:
  - short intro to site?
  - recent posts
-}

import           Hakyll
import           System.FilePath (replaceExtension, takeFileName)

postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" <> defaultContext

-- | Static pages in the content/ directory are passed through, keeping their
-- layout.
staticContent :: Rules ()
staticContent = match "content/*" $ do
  route $ customRoute ((`replaceExtension` ".html") . takeFileName . toFilePath)
  compile $ pandocCompiler
    >>= loadAndApplyTemplate "templates/default.html" defaultContext
    >>= relativizeUrls

postsContent :: Rules ()
postsContent = do
  create ["posts/index.html"] $ do
    route idRoute
    compile $ do
      posts <- loadAll "posts/*.markdown" >>= recentFirst
      let archiveCtx = listField "posts" postCtx (pure posts)
            <> constField "title" "Posts"
            <> defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/post-list.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  match "posts/*.markdown" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
      route   idRoute
      compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    staticContent
    postsContent

    match "index.html" $ do
      route idRoute
      compile $ do
        posts <- fmap (take 3) . recentFirst =<< loadAll "posts/*.markdown"
        let indexCtx = listField "posts" postCtx (return posts) `mappend` defaultContext

        getResourceBody
          >>= applyAsTemplate indexCtx
          >>= loadAndApplyTemplate "templates/default.html" indexCtx
          >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler
