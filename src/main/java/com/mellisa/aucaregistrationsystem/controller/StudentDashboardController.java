package com.mellisa.aucaregistrationsystem.controller;

import com.itextpdf.text.DocumentException;
import com.mellisa.aucaregistrationsystem.model.Course;
import com.mellisa.aucaregistrationsystem.model.Registration;
import com.mellisa.aucaregistrationsystem.model.Student;
import com.mellisa.aucaregistrationsystem.model.Users;
import com.mellisa.aucaregistrationsystem.services.CourseService;
import com.mellisa.aucaregistrationsystem.services.ExportPdfCourses;
import com.mellisa.aucaregistrationsystem.services.RegistrationService;
import com.mellisa.aucaregistrationsystem.services.StudentService;
import com.mellisa.aucaregistrationsystem.types.ERegistrationStatus;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.core.HttpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.net.http.HttpRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/student")
public class StudentDashboardController {

    @Autowired
    private StudentService studentService;

    @Autowired
    private CourseService courseService;

    @Autowired
    private RegistrationService registrationService;
    @Autowired
    private ExportPdfCourses coursePdfService;

    @GetMapping
    public String showDashboard(Model model, RedirectAttributes redirectAttributes, HttpSession session) {
        // Get the logged-in user from the session
        Users loggedInUser = (Users) session.getAttribute("loggedInUser");
        if (loggedInUser == null || !"Student".equalsIgnoreCase(loggedInUser.getRole().toString())) {
            return "redirect:/login";
        }

        Student student= studentService.findStudentByUser(loggedInUser);
        if (student==null) {
            redirectAttributes.addFlashAttribute("success", null);
            redirectAttributes.addFlashAttribute("error", "Student not found.");
            return "error";
        }


        // Fetch the list of available and registered courses
        List<Course> availableCourses = courseService.getAllCourses();
        List<Registration> registeredCourses = student.getRegistrations();

        // Calculate total credits
        int totalCredits = registeredCourses.stream().mapToInt(reg -> reg.getCourse().getCreditHours()).sum();

        model.addAttribute("student", student);
        model.addAttribute("availableCourses", availableCourses);
        model.addAttribute("registeredCourses", registeredCourses);
        model.addAttribute("totalCredits", totalCredits);

        return "studentDashboard";
    }

    // Handle course registration
    @PostMapping("/registerCourse")
    public String registerCourse(@RequestParam Long courseId, HttpSession session, RedirectAttributes redirectAttributes) {
        Users loggedInUser = (Users) session.getAttribute("loggedInUser");
        if (loggedInUser == null || !"Student".equalsIgnoreCase(loggedInUser.getRole().toString())) {
            return "redirect:/login";
        }

        Student student = studentService.findStudentByUser(loggedInUser);
        if (student==null) {
            redirectAttributes.addFlashAttribute("success", null);
            redirectAttributes.addFlashAttribute("error", "Student not found.");
            return "error";
        }

        Optional<Course> courseOptional = courseService.getCourseById(courseId);
        if (courseOptional.isEmpty()) {
            redirectAttributes.addFlashAttribute("success", null);
            redirectAttributes.addFlashAttribute("error", "Course not found.");
            return "error";
        }

        Course course = courseOptional.get();
        if (course.getRegisteredStudents() >= course.getMaxStudents()) {
            redirectAttributes.addFlashAttribute("success", null);
            redirectAttributes.addFlashAttribute("error", "Course is already full.");
            return "redirect:/student";
        }
        boolean alreadyRegistered = student.getRegistrations().stream()
                .anyMatch(reg -> reg.getCourse().getId().equals(courseId));
        if (alreadyRegistered) {
            redirectAttributes.addFlashAttribute("success", null);
            redirectAttributes.addFlashAttribute("error", "You have already registered for this course.");
            return "redirect:/student";
        }

        // Calculate total credits
        int totalCredits = student.getRegistrations().stream().mapToInt(reg -> reg.getCourse().getCreditHours()).sum();
        if (totalCredits + course.getCreditHours() > 20) {
            redirectAttributes.addFlashAttribute("success", null);
             redirectAttributes.addFlashAttribute("error", "Total credit hours exceeded the maximum limit of 20.");
             return "redirect:/student";
        }

        // Create a new registration
        Registration registration = new Registration();
        registration.setCourse(course);
        registration.setStudent(student);
        registration.setRegistrationDate(LocalDate.now());
        registration.setStatus(ERegistrationStatus.PENDING);

        registrationService.registerCourse(registration);
        course.setRegisteredStudents(course.getRegisteredStudents()+1);
        courseService.updateCourse(course.getId(),course);
        redirectAttributes.addFlashAttribute("error", null);
        redirectAttributes.addFlashAttribute("success", "Course registered successfully.");

        return "redirect:/student";
    }

    // Handle dropping a course
    @PostMapping("/dropCourse")
    public String dropCourse(@RequestParam Long registrationId, HttpSession session, RedirectAttributes redirectAttributes) {
        Users loggedInUser = (Users) session.getAttribute("loggedInUser");
        if (loggedInUser == null || !"Student".equalsIgnoreCase(loggedInUser.getRole().toString())) {
            return "redirect:/login";
        }

        Optional<Registration> registrationOptional = registrationService.getRegistrationById(registrationId);
        if (registrationOptional.isEmpty()) {
            redirectAttributes.addFlashAttribute("success", null);
            redirectAttributes.addFlashAttribute("error", "Registration not found.");
            return "error";
        }
        Registration registration = registrationOptional.get();
        Optional<Course> courseOptional = courseService.getCourseById(registration.getCourse().getId());
        if (courseOptional.isEmpty()) {
            redirectAttributes.addFlashAttribute("success", null);
            redirectAttributes.addFlashAttribute("error", "Course not found.");
            return "error";
        }
        Course course = courseOptional.get();
        registrationService.deleteRegistration(registrationId);
        course.setRegisteredStudents(course.getRegisteredStudents()-1);
        courseService.updateCourse(course.getId(),course);

        return "redirect:/student";
    }

    @GetMapping("/export-courses")
    public void exportCoursesToPdf(HttpServletResponse response) throws DocumentException, IOException {
        response.setContentType("application/pdf");
        response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=all_courses.pdf");

        List<Course> courses = courseService.getAllCourses();
        coursePdfService.exportCoursesToPdf(response, courses);
    }
}
