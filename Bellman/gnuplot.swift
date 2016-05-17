import Foundation

func gnuplot(name: String, args: [String]) -> Bool {
    let task = NSTask()
    task.launchPath = "/usr/local/bin/gnuplot"
    task.arguments = ["-p"]

    let stdinPipe = NSPipe()
    task.standardInput = stdinPipe
    let stdinHandle = stdinPipe.fileHandleForWriting

    let args = ["set terminal jpeg", "set output  \"\(name).jpg\""] + args + [""]
    
    if let data = (args.joinWithSeparator("\n") + "\n").dataUsingEncoding(NSUTF8StringEncoding) {
        stdinHandle.writeData(data)
        stdinHandle.closeFile()
    }

    task.launch()
    task.waitUntilExit()
    
    return task.terminationStatus == 0
}