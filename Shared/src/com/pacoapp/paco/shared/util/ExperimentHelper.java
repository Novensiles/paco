package com.pacoapp.paco.shared.util;

import java.util.ArrayList;
import java.util.List;

import com.google.common.collect.Lists;
import com.pacoapp.paco.shared.model2.ActionTrigger;
import com.pacoapp.paco.shared.model2.ExperimentDAO;
import com.pacoapp.paco.shared.model2.ExperimentGroup;
import com.pacoapp.paco.shared.model2.Input2;
import com.pacoapp.paco.shared.model2.InterruptCue;
import com.pacoapp.paco.shared.model2.InterruptTrigger;
import com.pacoapp.paco.shared.model2.Schedule;
import com.pacoapp.paco.shared.model2.ScheduleTrigger;

public class ExperimentHelper {

  public static Input2 getInputWithName(ExperimentDAO experiment, String name, String groupName) {
    if (name == null || name.isEmpty()) {
      return null;
    }
    List<Input2> inputs = null;
    if (groupName == null || groupName.isEmpty()) {
      inputs = getInputs(experiment);
    } else {
      ExperimentGroup group = experiment.getGroupByName(groupName);
      if (group != null) {
        inputs = group.getInputs();
      }
    }
    if (inputs != null) {
      for (Input2 input : inputs) {
        if (name.equals(input.getName())) {
          return input;
        }
      }
    }
    return null;
  }

  public static List<Input2> getInputs(ExperimentDAO experiment) {
    List<Input2> inputs = new java.util.ArrayList<Input2>();
    for (ExperimentGroup group : experiment.getGroups()) {
      inputs.addAll(group.getInputs());
    }
    return inputs;
  }

  public static boolean declaresLogAppUsageAndBrowserCollection(ExperimentDAO experiment) {
    return experiment.getExtraDataCollectionDeclarations() != null
            && experiment.getExtraDataCollectionDeclarations().contains(ExperimentDAO.APP_USAGE_BROWSER_HISTORY_DATA_COLLECTION);
  }

  public static boolean declaresInstalledAppDataCollection(ExperimentDAO experiment) {
    return experiment.getExtraDataCollectionDeclarations() != null
            && experiment.getExtraDataCollectionDeclarations().contains(ExperimentDAO.APP_INSTALL_DATA_COLLECTION);
  }

  /**
   * Returns whether the experiment has the accessibility logging flag set by the experiment
   * organiser.
   * @param experiment The running experiment
   * @return Whether accessibility logging is enabled for the experiment.
   */
  public static boolean declaresAccessibilityLogging(ExperimentDAO experiment) {
    return experiment.getExtraDataCollectionDeclarations() != null
            && experiment.getExtraDataCollectionDeclarations().contains(ExperimentDAO.ACCESSIBILITY_LOGGING);
  }

  public static boolean hasUserEditableSchedule(ExperimentDAO experiment) {
    List<ExperimentGroup> experimentGroups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : experimentGroups) {
      List<ActionTrigger> triggers = experimentGroup.getActionTriggers();
      for (ActionTrigger actionTrigger : triggers) {
        if (actionTrigger instanceof ScheduleTrigger) {
          ScheduleTrigger scheduleTrigger = (ScheduleTrigger)actionTrigger;
          List<Schedule> schedules = scheduleTrigger.getSchedules();
          for (Schedule schedule : schedules) {
            if (schedule.getUserEditable()) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  public static boolean hasAppUsageTrigger(ExperimentDAO experiment) {
    List<ExperimentGroup> groups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : groups) {
      List<ActionTrigger> triggers = experimentGroup.getActionTriggers();
      for (ActionTrigger actionTrigger : triggers) {
        if (actionTrigger instanceof InterruptTrigger) {
          InterruptTrigger trigger = (InterruptTrigger)actionTrigger;
          List<InterruptCue> cues = trigger.getCues();
          for (InterruptCue interruptCue : cues) {
            if (interruptCue.getCueCode() == InterruptCue.APP_USAGE ||
                    interruptCue.getCueCode() == InterruptCue.APP_CLOSED) {
              return true;
            }
          }

        }
      }
    }
    return false;
  }

  public static boolean hasAppClosedTrigger(ExperimentDAO experiment) {
    List<ExperimentGroup> groups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : groups) {
      List<ActionTrigger> triggers = experimentGroup.getActionTriggers();
      for (ActionTrigger actionTrigger : triggers) {
        if (actionTrigger instanceof InterruptTrigger) {
          InterruptTrigger trigger = (InterruptTrigger)actionTrigger;
          List<InterruptCue> cues = trigger.getCues();
          for (InterruptCue interruptCue : cues) {
            if (interruptCue.getCueCode() == InterruptCue.APP_CLOSED) {
              return true;
            }
          }

        }
      }
    }
    return false;
  }

  public static boolean isLogPhoneOnOff(ExperimentDAO experiment) {
    List<ExperimentGroup> groups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : groups) {
      if (experimentGroup.getLogShutdown()) {
        return true;
      }
    }
    return false;
  }


  public static boolean isLogActions(ExperimentDAO experiment) {
    List<ExperimentGroup> groups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : groups) {
      if (experimentGroup.getLogActions()) {
        return true;
      }
    }
    return false;
  }

  public static boolean shouldWatchProcesses(ExperimentDAO experiment) {
    return hasAppUsageTrigger(experiment) || isLogActions(experiment);
  }

  public static class Pair<S, T> {
    public S first;
    public T second;

    public Pair(S first, T second) {
      super();
      this.first = first;
      this.second = second;
    }
  }

  public static class Trio<S, T, U> {
    public S first;
    public T second;
    public U third;

    public Trio(S first, T second, U third) {
      super();
      this.first = first;
      this.second = second;
      this.third = third;
    }
  }


  @SuppressWarnings("unchecked")
  public static List<Trio<ExperimentGroup, InterruptTrigger, InterruptCue>> shouldTriggerBy(ExperimentDAO experiment,
                                                                                            int event,
                                                                                            String sourceIdentifier,
                                                                                            String packageName,
                                                                                            String className,
                                                                                            String eventText,
                                                                                            String eventContentDescription) {
    List<Trio<ExperimentGroup, InterruptTrigger, InterruptCue>> groupsThatTrigger = new ArrayList();
    List<ExperimentGroup> groups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : groups) {
      List<ActionTrigger> triggers = experimentGroup.getActionTriggers();
      for (ActionTrigger actionTrigger : triggers) {
        if (actionTrigger instanceof InterruptTrigger) {
          InterruptTrigger trigger = (InterruptTrigger) actionTrigger;
          List<InterruptCue> cues = trigger.getCues();
          for (InterruptCue interruptCue : cues) {
            boolean cueCodeMatches = interruptCue.getCueCode() == event;
            if (!cueCodeMatches) {
              continue;
            }

            boolean usesSourceId = interruptUsesSourceId(interruptCue);
            boolean cueFiltersMatch;
            boolean isExperimentTrigger = isExperimentEventTrigger(interruptCue);

            boolean triggerSourceIdIsEmpty = interruptCue.getCueSource() == null || interruptCue.getCueSource().isEmpty() ;
            if (usesSourceId) {
              if (interruptCue.getCueCode() == InterruptCue.ACCESSIBILITY_EVENT_VIEW_CLICKED) {
                cueFiltersMatch = isMatchingViewClickEvent(packageName, className, eventContentDescription,
                                                          interruptCue);
              } else {
                boolean paramEmpty = sourceIdentifier == null || sourceIdentifier.isEmpty();
                cueFiltersMatch = (paramEmpty && triggerSourceIdIsEmpty) ||
                        interruptCue.getCueSource().equals(sourceIdentifier);
              }
            } else if (isExperimentTrigger) {
              boolean paramExists = sourceIdentifier != null && !sourceIdentifier.isEmpty();
              boolean sameExperiment = Long.parseLong(sourceIdentifier) == experiment.getId();
              cueFiltersMatch = paramExists == true && sameExperiment == true;
            } else {
              cueFiltersMatch = true;
            }
            if (cueCodeMatches && cueFiltersMatch) {
              groupsThatTrigger.add(new Trio<ExperimentGroup, InterruptTrigger, InterruptCue>(experimentGroup, trigger, interruptCue));
            }
          }
        }
      }
    }
    return groupsThatTrigger;
  }

  private static boolean isExperimentEventTrigger(InterruptCue interruptCue) {
    return interruptCue.getCueCode() == InterruptCue.PACO_EXPERIMENT_JOINED_EVENT
            || interruptCue.getCueCode() == InterruptCue.PACO_EXPERIMENT_ENDED_EVENT
            || interruptCue.getCueCode() == InterruptCue.PACO_EXPERIMENT_RESPONSE_RECEIVED_EVENT;
  }

  private static boolean interruptUsesSourceId(InterruptCue interruptCue) {
    return interruptCue.getCueCode() == InterruptCue.PACO_ACTION_EVENT
            || interruptCue.getCueCode() == InterruptCue.APP_USAGE
            || interruptCue.getCueCode() == InterruptCue.APP_CLOSED
            || interruptCue.getCueCode() == InterruptCue.ACCESSIBILITY_EVENT_VIEW_CLICKED;
  }

  private static boolean isMatchingViewClickEvent(String packageName, String className, String eventContentDescription,
                                                  InterruptCue interruptCue) {
    if (interruptCue.getCueSource() != null) {
      if (packageName == null || !interruptCue.getCueSource().equals(packageName)) {
        return false;
      }
    }
    if (interruptCue.getCueAEContentDescription() != null) {
      if (eventContentDescription == null || !interruptCue.getCueAEContentDescription().equals(eventContentDescription)) {
        return false;
      }
    }
    if (interruptCue.getCueAEClassName() != null) {
      if (className == null || !interruptCue.getCueAEClassName().equals(className)) {
        return false;
      }
    }
    return true;
  }

  public static boolean isAnyGroupOngoingDuration(ExperimentDAO experiment) {
    List<ExperimentGroup> groups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : groups) {
      if (!experimentGroup.getFixedDuration()) {
        return true;
      }
    }
    return false;
  }

  public static List<ExperimentGroup> isBackgroundListeningForSourceId(ExperimentDAO experiment, String sourceIdentifier) {
    List<ExperimentGroup> listeningExperimentGroups  = new ArrayList();
    List<ExperimentGroup> experimentGroups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : experimentGroups) {
      if (experimentGroup.getBackgroundListen()) {
        String sourceFilter = experimentGroup.getBackgroundListenSourceIdentifier();
        if (sourceFilter.equals("*") || sourceFilter.equals(sourceIdentifier)) {
          listeningExperimentGroups.add(experimentGroup);
        }
      }
    }
    return listeningExperimentGroups;
  }

  /**
   * Returns all experiment groups listening for accessibility events. If Paco gets extended to
   * capture multiple accessibility events (apart from just permission events), this method could
   * be extended to include a source identifier.
   * @param experiment The experiment for which to get matching experiment groups
   * @return A list of experiment groups listening for accessibility events
   */
  public static List<ExperimentGroup> isListeningForAccessibilityEvents(ExperimentDAO experiment) {
    List<ExperimentGroup> listeningExperimentGroups = new ArrayList();
    List<ExperimentGroup> experimentGroups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : experimentGroups) {
      if (experimentGroup.getAccessibilityListen()) {
        listeningExperimentGroups.add(experimentGroup);
      }
    }
    return listeningExperimentGroups;
  }

  public static boolean doesAnyExperimentCareAboutAccessibilityEvents(List<ExperimentDAO> experiments) {
    for (ExperimentDAO experimentDAO : experiments) {
      if (!isListeningForAccessibilityEvents(experimentDAO).isEmpty()) {
        return true;
      }
      if (!getAccessibilityTriggers(experimentDAO).isEmpty()) {
        return true;
      }
    }
    return false;
  }

  public static List<InterruptTrigger> getAccessibilityTriggersForAllExperiments(List<ExperimentDAO> experiments) {
    List<InterruptTrigger> matching = Lists.newArrayList();
    for (ExperimentDAO experimentDAO : experiments) {
      List<InterruptTrigger> triggers = getAccessibilityTriggers(experimentDAO);
      if (!triggers.isEmpty()) {
        matching.addAll(triggers);
      }
    }
    return matching;
  }

  public static List<InterruptTrigger> getAccessibilityTriggers(ExperimentDAO experiment) {
    List<InterruptTrigger> matching = Lists.newArrayList();

    List<ExperimentGroup> groups = experiment.getGroups();
    for (ExperimentGroup experimentGroup : groups) {
      List<ActionTrigger> triggers = experimentGroup.getActionTriggers();
      for (ActionTrigger actionTrigger : triggers) {
        if (actionTrigger instanceof InterruptTrigger) {
          InterruptTrigger trigger = (InterruptTrigger)actionTrigger;
          List<InterruptCue> cues = trigger.getCues();
          for (InterruptCue interruptCue : cues) {
            if (interruptCue.getCueCode() == InterruptCue.ACCESSIBILITY_EVENT_VIEW_CLICKED ||
                    interruptCue.getCueCode() == InterruptCue.PERMISSION_CHANGED) {
              matching.add(trigger);
            }
          }

        }
      }
    }
    return matching;
  }

}
