package com.mellisa.aucaregistrationsystem.services;

import com.itextpdf.text.*;
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
public class ExportPdfRegistrations {

public void exportRegistrationsToPdf(HttpServletResponse response, List<Registration> registrations) throws DocumentException, IOException {
    Document document = new Document(PageSize.A4);
    PdfWriter.getInstance(document, response.getOutputStream());

    document.open();

    // Add title and date
    PdfPTable titleTable = new PdfPTable(2); // Create a table with 2 columns
    titleTable.setWidthPercentage(100f);
    titleTable.setSpacingAfter(10f);

    // Title cell (aligned to the left)
    Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
    PdfPCell titleCell = new PdfPCell(new Phrase("All Registration Requests", titleFont));
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

    document.add(titleTable); // Add the title table to the document

    // Add table with course details
    PdfPTable table = new PdfPTable(4);
    table.setWidthPercentage(100f);
    table.setSpacingBefore(10f);

    // Table headers
    addTableHeader(table);

    // Table rows
    for (Registration registration : registrations) {
        addTableRow(table, registration);
    }

    document.add(table);
    document.close();
}

        private void addTableHeader(PdfPTable table) {
            PdfPCell cell = new PdfPCell();
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);

            cell.setPhrase(new Phrase("Student", headerFont));
            table.addCell(cell);

            cell.setPhrase(new Phrase("Course", headerFont));
            table.addCell(cell);

            cell.setPhrase(new Phrase("Date", headerFont));
            table.addCell(cell);

            cell.setPhrase(new Phrase("Status", headerFont));
            table.addCell(cell);
        }

        private void addTableRow(PdfPTable table, Registration registration) {
            table.addCell(registration.getStudent().getUser().getFirstName()+" "+registration.getStudent().getUser().getLastName());
            table.addCell(registration.getCourse().getCourseName());
            table.addCell(String.valueOf(registration.getRegistrationDate()));
            table.addCell(String.valueOf(registration.getStatus()));
        }
    }


