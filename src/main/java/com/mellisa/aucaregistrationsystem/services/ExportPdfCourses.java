package com.mellisa.aucaregistrationsystem.services;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.mellisa.aucaregistrationsystem.model.Course;
import com.mellisa.aucaregistrationsystem.model.Registration;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Service;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Service
public class ExportPdfCourses {

        public void exportCoursesToPdf(HttpServletResponse response, List<Course> courses) throws DocumentException, IOException {
            Document document = new Document(PageSize.A4);
            PdfWriter.getInstance(document, response.getOutputStream());

            document.open();

            PdfPTable titleTable = new PdfPTable(2); // Create a table with 2 columns
            titleTable.setWidthPercentage(100f);
            titleTable.setSpacingAfter(10f);


            // Title cell (aligned to the left)
            Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
            PdfPCell titleCell = new PdfPCell(new Phrase("All Courses", titleFont));
            titleCell.setBorder(PdfPCell.NO_BORDER);
            titleCell.setHorizontalAlignment(Element.ALIGN_LEFT);
            titleTable.addCell(titleCell);

            // Date cell (aligned to the right)
            String formattedDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
            Font dateFont = new Font(Font.FontFamily.HELVETICA, 12, Font.NORMAL);
            PdfPCell dateCell = new PdfPCell(new Phrase("Exported On: " + formattedDate, dateFont));
            dateCell.setBorder(PdfPCell.NO_BORDER);
            dateCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            titleTable.addCell(dateCell);

            document.add(titleTable);
            // Add table with course details
            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100f);
            table.setSpacingBefore(10f);

            // Table headers
            addTableHeader(table);

            // Table rows
            for (Course course : courses) {
                addTableRow(table, course);
            }

            document.add(table);
            document.close();
        }

        private void addTableHeader(PdfPTable table) {
            PdfPCell cell = new PdfPCell();
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);

            cell.setPhrase(new Phrase("Course Code", headerFont));
            table.addCell(cell);

            cell.setPhrase(new Phrase("Course Name", headerFont));
            table.addCell(cell);

            cell.setPhrase(new Phrase("Credit Hours", headerFont));
            table.addCell(cell);

            cell.setPhrase(new Phrase("Max Students", headerFont));
            table.addCell(cell);

            cell.setPhrase(new Phrase("Registered Students", headerFont));
            table.addCell(cell);
        }

        private void addTableRow(PdfPTable table, Course course) {
            table.addCell(course.getCourseCode());
            table.addCell(course.getCourseName());
            table.addCell(String.valueOf(course.getCreditHours()));
            table.addCell(String.valueOf(course.getMaxStudents()));
            table.addCell(String.valueOf(course.getRegisteredStudents()));
        }
    }


