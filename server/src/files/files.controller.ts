import { Controller, Get, Post, Body, Patch, Param, Delete, Res, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { FilesService } from './files.service';
import { CreateFileDto } from './dto/create-file.dto';
import { UpdateFileDto } from './dto/update-file.dto';
import { createReadStream } from 'fs';
import { join } from 'path';
import type { Response } from 'express';

@Controller('files')
export class FilesController {
  constructor(private readonly filesService: FilesService) { }

  @Post()
  create(@Body() createFileDto: CreateFileDto) {
    return this.filesService.create(createFileDto);
  }

  @Get()
  findAll() {
    return this.filesService.findAll();
  }

  @Get('download/:id')
  downloadGet(@Res() res: Response, @Param('id') id: number) {
    console.log(id, id == 2);
    
    if (id == 1) {
      const file = createReadStream(join(process.cwd(), 'assets_demo.zip'))
      file.pipe(res)
    }
    else if(id == 2){
      throw new UnauthorizedException('UnauthorizedException')
    }
    else if(id == 3){
      throw new ConflictException('ConflictException')
    }else{
      throw new BadRequestException('BadRequestException')
    }
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.filesService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateFileDto: UpdateFileDto) {
    return this.filesService.update(+id, updateFileDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.filesService.remove(+id);
  }
}
