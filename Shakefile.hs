import           Development.Shake          (cmd, need, phony, putNormal,
                                             removeFilesAfter, shakeArgs,
                                             shakeFiles, shakeOptions, want,
                                             (%>))
import           Development.Shake.Command  ()
import           Development.Shake.FilePath (dropDirectory1, exe, (-<.>), (<.>),
                                             (</>))
import           Development.Shake.Util     (needMakefileDependencies)

main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="_build"} $ do
    want ["_build/test1" <.> exe, "_build/pipe-sample" <.> exe]

    phony "clean" $ do
        putNormal "Cleaning files in _build"
        removeFilesAfter "_build" ["//*"]

    "_build/test1" <.> exe %> \out -> do
        let obj = out -<.> "o"
        need [obj]
        cmd "cc -o" [out] obj

    "_build/pipe-sample" <.> exe %> \out -> do
        let obj = out -<.> "o"
        need [obj]
        cmd "cc -o" [out] obj

    "_build//*.o" %> \out -> do
        let c = "src" </> (dropDirectory1 $ out -<.> "c")
        let m = out -<.> "m"
        () <- cmd "cc -c" [c] "-o" [out] "-MMD -MF" [m]
        needMakefileDependencies m
