<%-- Created by IntelliJ IDEA. User: hp Date: 11/2/2024 Time: 8:08 AM To change this template use File | Settings | File Templates. --%>
<%@ include file="sidebar.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title data-i18n="registrationInsightsTitle">Registration Insights</title>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Sharp" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-gray-100 p-6">
<jsp:include page="sidebar.jsp"/>
<div class="flex-1 p-6 ml-64">
    <h2 class="text-2xl font-bold text-blue-600 mb-6" data-i18n="registrationInsightsTitle">Registration Insights</h2>
    <div class="lg:flex-row gap-6">
        <!-- Pie Chart for Status Distribution -->
       <div class="flex flex-row gap-2 w-full">
           <div class="bg-white rounded-lg shadow-md p-4 w-full lg:w-1/2">
               <h3 class="text-xl font-bold mb-4" data-i18n="statusDistributionTitle">Registration Status Distribution</h3>
               <canvas id="statusDistributionChart" style="width: 350px; height: 350px; margin:auto;"></canvas>
           </div>

           <!-- Bar Chart for Registrations by Course -->
           <div class="bg-white rounded-lg shadow-md p-4 w-full lg:w-1/2">
               <h3 class="text-xl font-bold mb-4" data-i18n="registrationsPerCourseTitle">Registrations Per Course</h3>
               <canvas id="registrationsByCourseChart"></canvas>
           </div>
       </div>
        <div class="bg-white rounded-lg shadow-md p-4 w-full lg:w-1/2">
           <canvas id="circularLineChart" style="width: 350px; height: 350px; margin:auto;"></canvas>
        </div>
    </div>
</div>

<!-- Prepare Data for Charts -->
<script>
    const registrations = [
        <c:forEach items="${registrations}" var="registration" varStatus="loop">
        {
            status: "${registration.status}",
            course: "${registration.course.courseName}" // Accessing the course name directly
        }<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];

    // Generate status distribution data
    const statusCounts = registrations.reduce((counts, reg) => {
        counts[reg.status] = (counts[reg.status] || 0) + 1;
        return counts;
    }, {});

    const statusLabels = Object.keys(statusCounts);
    const statusValues = Object.values(statusCounts);

    // Count registrations by course
    const registrationsByCourse = registrations.reduce((counts, reg) => {
        counts[reg.course] = (counts[reg.course] || 0) + 1;
        return counts;
    }, {});

    const courseLabels = Object.keys(registrationsByCourse);
    const courseValues = Object.values(registrationsByCourse);
    const resources = {
        en: {
            translation: {
                dashboardTitle: "Admin Dashboard",
                allCourses: "All Courses",
                registrationRequests: "Registration Requests",
                insights: "Registration Insights",
                chooseLanguage: "Choose Language:",
                logout: "Logout",
                registrationInsightsTitle: "Registration Insights",
                statusDistributionTitle: "Registration Status Distribution",
                registrationsPerCourseTitle: "Registrations Per Course"
            }
        },
        es: {
            translation: {
                dashboardTitle: "Panel de Administración",
                allCourses: "Todos los Cursos",
                registrationRequests: "Solicitudes de Registro",
                insights: "Análisis de Registros",
                chooseLanguage: "Elegir Idioma:",
                logout: "Cerrar Sesión",
                registrationInsightsTitle: "Información de Registro",
                statusDistributionTitle: "Distribución del Estado de Registro",
                registrationsPerCourseTitle: "Registros por Curso"
            }
        },
        fr: {
            translation: {
                dashboardTitle: "Tableau de Bord Admin",
                allCourses: "Tous les Cours",
                registrationRequests: "Demandes d'Inscription",
                insights: "Analyses des Inscriptions",
                chooseLanguage: "Choisir la Langue:",
                logout: "Déconnexion",
                registrationInsightsTitle: "Aperçu des Inscriptions",
                statusDistributionTitle: "Distribution des Statuts d'Inscription",
                registrationsPerCourseTitle: "Inscriptions par Cours"
            }
        },
        rw: {
            translation: {
                dashboardTitle: "Ikibaho cy'Umuyobozi",
                allCourses: "Amasomo Yose",
                registrationRequests: "Ibisabwa byo Kwiyandikisha",
                insights: "Imibare y'Iyandikwa",
                chooseLanguage: "Hitamo Ururimi:",
                logout: "Sohoka",
                registrationInsightsTitle: "Ubusesenguzi bw'Iyandikwa",
                statusDistributionTitle: "Ihererekanyabubasha ryo kwiyandikisha",
                registrationsPerCourseTitle: "Iyandikwa rya buri somo"
            }
        }
    };
    // const resources = {
    //     en: { translation: { registrationInsightsTitle: "Registration Insights", statusDistributionTitle: "Registration Status Distribution", registrationsPerCourseTitle: "Registrations Per Course" } },
    //     es: { translation: { registrationInsightsTitle: "Información de Registro", statusDistributionTitle: "Distribución del Estado de Registro", registrationsPerCourseTitle: "Registros por Curso" } },
    //     fr: { translation: { registrationInsightsTitle: "Aperçu des Inscriptions", statusDistributionTitle: "Distribution des Statuts d'Inscription", registrationsPerCourseTitle: "Inscriptions par Cours" } },
    //     rw: { translation: { registrationInsightsTitle: "Ubusesenguzi bw'Iyandikwa", statusDistributionTitle: "Ihererekanyabubasha ryo kwiyandikisha", registrationsPerCourseTitle: "Iyandikwa rya buri somo" } }
    // };

    document.addEventListener("DOMContentLoaded", function () {

        i18next.init({
            lng: localStorage.getItem('preferredLanguage') || 'en',
            resources: resources,
            fallbackLng: 'en'
        }).then(function () {
            updateContent();
        });

        function updateContent() {
            document.querySelectorAll('[data-i18n]').forEach(element => {
                const key = element.getAttribute('data-i18n');
                element.textContent = i18next.t(key);
            });
        }

        window.changeLanguage = function (newLang) {
            localStorage.setItem('preferredLanguage', newLang);
            i18next.changeLanguage(newLang, function (err) {
                if (!err) updateContent();
            });
        };

        // Pie Chart for Status Distribution
        new Chart(document.getElementById("statusDistributionChart"), {
            type: 'pie',
            data: {
                labels: statusLabels,
                datasets: [{
                    data: statusValues,
                    backgroundColor: ['#4caf50', '#ffeb3b', '#f44336'],
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'top' },
                }
            }
        });

        // Bar Chart for Registrations by Course
        new Chart(document.getElementById("registrationsByCourseChart"), {
            type: 'bar',
            data: {
                labels: courseLabels,
                datasets: [{
                    label: 'Number of Registrations',
                    data: courseValues,
                    backgroundColor: '#42a5f5',
                    borderColor: '#1e88e5',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { display: false },
                },
                scales: {
                    x: { title: { display: true, text: 'Course' } },
                    y: { title: { display: true, text: 'Number of Registrations' } }
                }
            }
        });
        new Chart(document.getElementById("circularLineChart"), {
            type: 'polarArea',
            data: {
                labels: courseLabels, // Course names
                datasets: [{
                    label: 'Registrations per Course',
                    data: courseValues, // Number of registrations per course
                    backgroundColor: [
                        '#ff6384', '#36a2eb', '#cc65fe', '#ffce56', '#26a69a', '#42a5f5', '#8e44ad', '#d35400'
                    ], // Different colors for each course
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'right' }
                },
                scales: {
                    r: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                }
            }
        });
    });

</script>
</body>
</html>
