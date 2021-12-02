import { Injectable } from '@nestjs/common';
import { fromBase64, fromBuffer, fromPath } from "pdf2pic";
import { mkdirsSync } from 'fs-extra'
import * as rimraf from 'rimraf'
import * as path from 'path'
import * as fs from 'fs'
import * as PDFDocument from 'pdfkit'
@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World!';
  }

  async generateImage(file: any, postFixFileName: string): Promise<any> {
    // const specimen1 = path.join(__dirname, '../document2.pdf');
    const specimen1 = file

    const outputDirectory =  path.join(__dirname, `../outputimages/${postFixFileName}`);
    const saveFilename= 'resource-list-' + postFixFileName
    rimraf.sync(outputDirectory);

    mkdirsSync(outputDirectory);

    const baseOptions = {
      height: 2550,
      width: 3300,
      density: 330,
      savePath: outputDirectory,
      saveFilename,
      format: 'jpeg'
      
    };
    // const convert = fromBase64(specimen1, baseOptions)
    const convert = fromBuffer(specimen1.buffer, baseOptions)
    // const convert = fromPath(specimen1, baseOptions);
    await convert.bulk(-1);
    return {
      saveFilename,
      outputDirectory
    }
  }

  readFilesSync(dir: string, postFixFileName) {
    const files = [];
  
    fs.readdirSync(dir)
    .filter(filename => path.parse(filename).name.includes(postFixFileName))
    .forEach(filename => {
      const name = path.parse(filename).name;
      const ext = path.parse(filename).ext;
      const filepath = path.resolve(dir, filename);
      const stat = fs.statSync(filepath);
      const isFile = stat.isFile();
  
      if (isFile) files.push({ filepath, name, ext, stat });
    });
  
    files.sort((a, b) => {
      // natural sort alphanumeric strings
      // https://stackoverflow.com/a/38641281
      return a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' });
    });
  
    return files;
  }

  generatePDF(imageFiles: Array<any>, postFixFileName): any {
    const outputFile = path.join(__dirname, `../outputpdf/outputfile-${postFixFileName}.pdf`)
    const pageOption = {
      layout: 'landscape',
      size: 'a4'
    }
    const doc = new PDFDocument(pageOption);
    doc.pipe(fs.createWriteStream(outputFile));
    imageFiles.forEach( (element, index) => {
      const img = doc.openImage(element.filepath)
      if (index === 0) {
        doc.image(element.filepath , 0, 0, {
          width: 841.89,
          height: 595.28
        });
      } else {
        doc.addPage(pageOption).image(element.filepath , 0, 0, {
          width: 841.89,
          height: 595.28
        });
      }
    });
    doc.end();

    return {
      outputFile
    }
  }

  deletingDirFile(path: string, type: string): void {
    if (type === 'dir') {
      fs.rmSync(path, { force: true, recursive: true })
    } else if (type === 'file') {
      fs.rmSync(path, { force: true })
    }
 }

}
