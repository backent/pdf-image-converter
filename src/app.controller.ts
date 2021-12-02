import { Controller, Get, Header, HttpCode, Post, StreamableFile, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AppService } from './app.service';
import * as fs from 'fs'
import * as path from 'path'

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('/ping')
  getHello(): string {
    return 'PING PONG'
  }

  @Post()
  @UseInterceptors(FileInterceptor('file'))
  // @HttpCode(201)
  // @Header('Content-Type', 'image/pdf')
  // @Header('Content-Disposition', 'inline; filename=test.pdf')
  async generate(@UploadedFile() file: Express.Multer.File): Promise<StreamableFile> {
    const postFixFileName = new Date().getTime().toString()
    const { outputDirectory } =  await this.appService.generateImage(file, postFixFileName)
    const files = this.appService.readFilesSync(outputDirectory, postFixFileName)
    const { outputFile } = this.appService.generatePDF(files, postFixFileName)
    const outputfileo = fs.createReadStream(outputFile)
    this.appService.deletingDirFile(outputDirectory, 'dir')
    this.appService.deletingDirFile(outputFile, 'file')
    return new StreamableFile(outputfileo)
  }
}
